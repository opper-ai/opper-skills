#!/usr/bin/env bash
# Validates all SKILL.md files in the repo against the Agent Skills spec.
# Exits 0 if all checks pass, 1 on any failure.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
errors=0

for skill_file in "$REPO_ROOT"/*/SKILL.md "$REPO_ROOT"/guides/*/SKILL.md "$REPO_ROOT"/media/*/SKILL.md; do
  [ -f "$skill_file" ] || continue

  dir_name="$(basename "$(dirname "$skill_file")")"
  # Path under the repo root (opper-api, guides/video-production, media/product-ad): the served URL and versions.json key.
  rel_dir="${skill_file#"$REPO_ROOT"/}"; rel_dir="${rel_dir%/SKILL.md}"

  # --- Check 1: SKILL.md under 500 lines ---
  line_count="$(wc -l < "$skill_file" | tr -d ' ')"
  if [ "$line_count" -gt 500 ]; then
    echo "ERROR: $dir_name/SKILL.md has $line_count lines (max 500)"
    errors=$((errors + 1))
  fi

  # --- Extract frontmatter (between first pair of ---) ---
  frontmatter="$(awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$skill_file")"

  # --- Check 2: name field matches parent directory ---
  # Handle both single-line (name: foo) and multi-line (name: >\n  foo)
  name="$(echo "$frontmatter" | awk '
    /^name:/ {
      sub(/^name:[[:space:]]*/, "")
      if ($0 != "" && $0 != ">") { print $0; exit }
      getline; sub(/^[[:space:]]+/, ""); print; exit
    }
  ')"

  if [ -z "$name" ]; then
    echo "ERROR: $dir_name/SKILL.md missing 'name' field in frontmatter"
    errors=$((errors + 1))
  elif [ "$name" != "$dir_name" ]; then
    echo "ERROR: $dir_name/SKILL.md has name '$name' but directory is '$dir_name'"
    errors=$((errors + 1))
  fi

  # --- Check 3: name is lowercase alphanumeric + hyphens only ---
  if [ -n "$name" ]; then
    if ! echo "$name" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
      echo "ERROR: $dir_name/SKILL.md name '$name' must be lowercase alphanumeric and hyphens only"
      errors=$((errors + 1))
    fi
  fi

  # --- Check 3a: name max 64 chars ---
  if [ -n "$name" ] && [ "${#name}" -gt 64 ]; then
    echo "ERROR: $dir_name/SKILL.md name is ${#name} chars (max 64)"
    errors=$((errors + 1))
  fi

  # --- Check 3b: name does not contain reserved words (anthropic, claude) ---
  if [ -n "$name" ] && echo "$name" | grep -qiE '(^|-)(anthropic|claude)(-|$)'; then
    echo "ERROR: $dir_name/SKILL.md name '$name' contains a reserved word (anthropic, claude)"
    errors=$((errors + 1))
  fi

  # --- Check 4: description under 1024 chars ---
  # Collect the full description value, handling multi-line YAML scalars (> or |)
  description="$(echo "$frontmatter" | awk '
    /^description:/ {
      sub(/^description:[[:space:]]*/, "")
      if ($0 != "" && $0 != ">" && $0 != "|") { print $0; exit }
      # Multi-line: collect indented continuation lines
      while ((getline line) > 0) {
        if (line ~ /^[[:space:]]/) {
          sub(/^[[:space:]]+/, "", line)
          printf "%s ", line
        } else {
          break
        }
      }
      exit
    }
  ')"

  desc_len="${#description}"
  if [ "$desc_len" -gt 1024 ]; then
    echo "ERROR: $dir_name/SKILL.md description is $desc_len chars (max 1024)"
    errors=$((errors + 1))
  fi

  # --- Check 5: description is non-empty ---
  if [ "$desc_len" -eq 0 ]; then
    echo "ERROR: $dir_name/SKILL.md missing or empty 'description' field in frontmatter"
    errors=$((errors + 1))
  fi

  # --- Check 6: metadata.version is a date, and the version-check block agrees ---
  # scripts/bump-version.sh writes both; this catches hand edits that drift.
  version="$(bash "$REPO_ROOT/scripts/skill-version.sh" "$skill_file")"
  if ! echo "$version" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}(\.[0-9]+)?$'; then
    echo "ERROR: $dir_name/SKILL.md metadata.version '$version' must be YYYY-MM-DD or YYYY-MM-DD.N (run scripts/bump-version.sh $dir_name)"
    errors=$((errors + 1))
  elif [ "${rel_dir#media/}" != "$rel_dir" ]; then
    : # Media skills carry no version-check block: see the media checks below.
  elif [ "$(grep -c '^<!-- version-check' "$skill_file")" -ne 1 ] \
    || ! grep -qF "> **Skill version $version.**" "$skill_file" \
    || ! grep -qF "https://skills.opper.ai/$rel_dir/SKILL.md" "$skill_file"; then
    echo "ERROR: $dir_name/SKILL.md version-check block is missing or does not match metadata.version $version (run scripts/bump-version.sh $rel_dir)"
    errors=$((errors + 1))
  fi
done

# --- Media skills (media/<name>/SKILL.md): recipes for the Opper Media tools ---
# They ship as the opper-media plugin and a copy is built into the Opper Media
# MCP server, so each one stands alone: it tells the assistant to fetch nothing
# (no version-check block, no skills.opper.ai link) and repeats the same rules
# as every other media skill.
rules_of() { awk '/^## Rules for every step$/{on=1} on{print}' "$1"; }
first_rules=""
for skill_file in "$REPO_ROOT"/media/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  name="$(basename "$(dirname "$skill_file")")"
  if grep -qE 'version-check|skills\.opper\.ai' "$skill_file"; then
    echo "ERROR: media/$name/SKILL.md must not ask the assistant to fetch anything (version-check block or skills.opper.ai link)"
    errors=$((errors + 1))
  fi
  if grep -q '—' "$skill_file"; then
    echo "ERROR: media/$name/SKILL.md has an em dash"
    errors=$((errors + 1))
  fi
  if ! grep -q '^# ' "$skill_file" || ! grep -q '^## Inputs$' "$skill_file" || ! grep -q '^## Steps$' "$skill_file" \
    || ! grep -qE '^- \*\*[^*]+\*\* \(required\): ' "$skill_file"; then
    echo "ERROR: media/$name/SKILL.md needs a '# Title', '## Inputs' with at least one '- **Name** (required): ...' line, and '## Steps' (the MCP server builds its prompts from them)"
    errors=$((errors + 1))
  fi
  rules="$(rules_of "$skill_file")"
  if [ -z "$rules" ]; then
    echo "ERROR: media/$name/SKILL.md has no '## Rules for every step' section"
    errors=$((errors + 1))
  elif [ -z "$first_rules" ]; then
    first_rules="$rules"
  elif [ "$rules" != "$first_rules" ]; then
    echo "ERROR: media/$name/SKILL.md '## Rules for every step' differs from the other media skills; keep the section identical in all of them"
    errors=$((errors + 1))
  fi
  if ! grep -q "\"$name\"" "$REPO_ROOT/media/.cursor-plugin/plugin.json"; then
    echo "ERROR: media/$name is missing from the skills list in media/.cursor-plugin/plugin.json"
    errors=$((errors + 1))
  fi
done

if [ "$errors" -gt 0 ]; then
  echo ""
  echo "Validation failed with $errors error(s)"
  exit 1
fi

echo "All SKILL.md files are valid"
exit 0
