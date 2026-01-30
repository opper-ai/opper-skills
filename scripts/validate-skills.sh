#!/usr/bin/env bash
# Validates all SKILL.md files in the repo against the Agent Skills spec.
# Exits 0 if all checks pass, 1 on any failure.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
errors=0

for skill_file in "$REPO_ROOT"/*/SKILL.md; do
  [ -f "$skill_file" ] || continue

  dir_name="$(basename "$(dirname "$skill_file")")"

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
done

if [ "$errors" -gt 0 ]; then
  echo ""
  echo "Validation failed with $errors error(s)"
  exit 1
fi

echo "All SKILL.md files are valid"
exit 0
