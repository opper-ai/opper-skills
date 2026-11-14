#!/usr/bin/env bash
#
# Build the copy of the Opper plugin that Claude's plugin directory installs.
#
# The directory accepts only Markdown, text, JSON, YAML and a few image types
# from organizations it has not verified, and only plain skill frontmatter.
# This repo also holds scripts, git hooks, an SVG logo, the Cursor and Gemini
# manifests and frontmatter keys (metadata, category, parent) that the other
# installers rely on, so the directory refused it as it stands. This script
# writes a clean plugin into a folder; .github/workflows/claude-plugin.yml
# pushes that folder to the claude-plugin branch on every push to main, and the
# directory tracks that branch. Never edit the claude-plugin branch by hand.
#
# What goes in:
#   .claude-plugin/plugin.json  this repo's, with skills under ./skills/ and a PNG icon
#   skills/<name>/SKILL.md      each skill plugin.json lists, frontmatter cut to
#                               name + description, version-check block removed
#   skills/<name>/references/   the skill's reference Markdown
#   .mcp.json, LICENSE, README.md, assets/opper-icon.png
#
# Deliberately dumb, like build-site.sh: no eval, no executing repo content,
# only cp/find/awk/jq.
#
# Usage:
#   scripts/build-claude-plugin.sh             # build into ./_claude-plugin
#   scripts/build-claude-plugin.sh <out-dir>   # build into <out-dir>
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUT="${1:-_claude-plugin}"
MANIFEST=".claude-plugin/plugin.json"
ICON="assets/opper-icon.png"

for f in "$MANIFEST" .mcp.json LICENSE "$ICON"; do
  [[ -f "$f" ]] || { echo "FATAL: $f not found." >&2; exit 1; }
done

rm -rf "$OUT"
mkdir -p "$OUT/.claude-plugin" "$OUT/skills" "$OUT/assets"

# Frontmatter: keep name: and description: (with their indented continuation
# lines), drop every other key. Body: drop the local-only version-check block,
# as build-site.sh does for skills.opper.ai; the directory ships updates itself.
clean_skill() {
  awk '
    NR == 1 && /^---$/ { fm = 1; print; next }
    fm && /^---$/ { fm = 0; body = 1; print; next }
    fm {
      if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) { keep = ($0 ~ /^(name|description):/) }
      if (keep) print
      next
    }
    /^<!-- version-check/ { skipping = 1; next }
    skipping { if ($0 ~ /^<!-- \/version-check -->/) { skipping = 0; drop_blank = 1 } next }
    drop_blank && $0 == "" { drop_blank = 0; next }
    { drop_blank = 0; print }
  ' "$1"
}

SKILLS=()
while IFS= read -r path; do
  SKILLS+=("${path#./}")
done < <(jq -r '.skills[]' "$MANIFEST")
[[ ${#SKILLS[@]} -gt 0 ]] || { echo "FATAL: $MANIFEST lists no skills." >&2; exit 1; }

for dir in "${SKILLS[@]}"; do
  src="$dir/SKILL.md"
  [[ -f "$src" ]] || { echo "FATAL: $src not found." >&2; exit 1; }
  name="$(basename "$dir")"
  mkdir -p "$OUT/skills/$name"
  clean_skill "$src" > "$OUT/skills/$name/SKILL.md"
  if [[ -d "$dir/references" ]]; then
    mkdir -p "$OUT/skills/$name/references"
    find "$dir/references" -type f -name '*.md' -exec cp {} "$OUT/skills/$name/references/" \;
  fi
done

jq --arg icon "./$ICON" '
  .skills = [.skills[] | "./skills/" + (sub("^\\./"; "") | split("/") | last)]
  | .icon = $icon
' "$MANIFEST" > "$OUT/.claude-plugin/plugin.json"
cp .mcp.json "$OUT/.mcp.json"
cp LICENSE "$OUT/LICENSE"
cp "$ICON" "$OUT/$ICON"

skill_list="$(printf '`%s`, ' "${SKILLS[@]##*/}")"
{
  echo "# Opper plugin for Claude"
  echo
  echo "Agent Skills for building on [Opper](https://opper.ai), the EU-hosted AI gateway, plus the Opper MCP server (\`https://api.opper.ai/mcp\`)."
  echo
  echo "- Skills: ${skill_list%, }. Start with \`opper\`."
  echo "- MCP server: search the model catalogue without an account; everything that touches your account asks you to sign in through the browser first."
  echo
  echo "This branch is generated from [opper-ai/opper-skills](https://github.com/opper-ai/opper-skills) by \`scripts/build-claude-plugin.sh\` on every push to \`main\`. Change the skills there, not here."
  echo
  echo "Docs: https://docs.opper.ai · MCP setup: https://opper.ai/mcp · Support: https://opper.ai/contact"
} > "$OUT/README.md"

# What the directory accepts from an unverified organization: Markdown, JSON,
# the license and PNG images, UTF-8 with no NUL bytes, nothing starting with #!,
# and SKILL.md frontmatter with only name and description.
fail=0
while IFS= read -r -d '' f; do
  case "$f" in
    *.md|*.json|*.png|*/LICENSE) ;;
    *) echo "FATAL: $f is not an allowed file type." >&2; fail=1; continue ;;
  esac
  case "$f" in
    *.png) continue ;;
  esac
  if [[ "$(head -c 2 "$f")" == "#!" ]]; then
    echo "FATAL: $f starts with #!." >&2; fail=1
  fi
  if tr -d '\000' < "$f" | cmp -s - "$f"; then :; else
    echo "FATAL: $f contains NUL bytes." >&2; fail=1
  fi
done < <(find "$OUT" -type f -print0)

for f in "$OUT"/skills/*/SKILL.md; do
  extra="$(awk '
    NR == 1 && /^---$/ { fm = 1; next }
    fm && /^---$/ { exit }
    fm && /^[A-Za-z_][A-Za-z0-9_-]*:/ && !/^(name|description):/ { print }
  ' "$f")"
  if [[ -n "$extra" ]]; then
    echo "FATAL: $f keeps frontmatter keys other than name and description: $extra" >&2; fail=1
  fi
  if grep -q 'version-check' "$f"; then
    echo "FATAL: $f still has a version-check block." >&2; fail=1
  fi
done
[[ $fail -eq 0 ]] || exit 1

echo "Built the Claude plugin into $OUT/ with ${#SKILLS[@]} skills:"
printf '  - %s\n' "${SKILLS[@]}"
