#!/usr/bin/env bash
#
# Build the Opper Media plugin as ChatGPT takes it.
#
# The media skills live in media/<name>/ in the form the other installers
# read. ChatGPT wants a folder of its own: a manifest with the listing, the
# ChatGPT media server, an icon, and each skill with plain frontmatter and its
# agents/openai.yaml. This script writes that folder from an explicit list of
# files, so nothing else in the repo can end up in the package:
#
#   plugin.json                        media/.chatgpt-plugin/plugin.json (the listing)
#   mcp.json                           media/.chatgpt-plugin/mcp.json (https://api.opper.ai/mcp/media-chatgpt)
#   assets/icon.png                    media/assets/icon.png
#   skills/<name>/SKILL.md             media/<name>/SKILL.md, frontmatter cut to name + description
#   skills/<name>/agents/openai.yaml   media/<name>/agents/openai.yaml
#
# It then checks what ChatGPT's submission rules fix: the listing's lengths,
# one to three starter prompts, and that no text in the package talks about
# money or names another product. Deliberately dumb, like build-site.sh: no
# eval, no executing repo content, only cp/find/awk/jq.
#
# Usage:
#   scripts/build-chatgpt-plugin.sh             # build into ./_chatgpt-plugin
#   scripts/build-chatgpt-plugin.sh <out-dir>   # build into <out-dir>
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUT="${1:-_chatgpt-plugin}"
MANIFEST="media/.chatgpt-plugin/plugin.json"
MCP="media/.chatgpt-plugin/mcp.json"
ICON="media/assets/icon.png"

for f in "$MANIFEST" "$MCP" "$ICON"; do
  [[ -f "$f" ]] || { echo "FATAL: $f not found." >&2; exit 1; }
done

rm -rf "$OUT"
mkdir -p "$OUT/assets" "$OUT/skills"
cp "$MANIFEST" "$OUT/plugin.json"
cp "$MCP" "$OUT/mcp.json"
cp "$ICON" "$OUT/assets/icon.png"

# Frontmatter: keep name: and description: (with their indented continuation
# lines), drop every other key.
clean_skill() {
  awk '
    NR == 1 && /^---$/ { fm = 1; print; next }
    fm && /^---$/ { fm = 0; print; next }
    fm {
      if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) { keep = ($0 ~ /^(name|description):/) }
      if (keep) print
      next
    }
    { print }
  ' "$1"
}

shopt -s nullglob
count=0
for src in media/*/SKILL.md; do
  name="$(basename "$(dirname "$src")")"
  yaml="media/$name/agents/openai.yaml"
  [[ -f "$yaml" ]] || { echo "FATAL: $yaml not found." >&2; exit 1; }
  mkdir -p "$OUT/skills/$name/agents"
  clean_skill "$src" > "$OUT/skills/$name/SKILL.md"
  cp "$yaml" "$OUT/skills/$name/agents/openai.yaml"
  # ChatGPT names a skill plugin-name:skill-name, 64 characters at most.
  if [[ $(( ${#name} + 12 )) -gt 64 ]]; then
    echo "FATAL: opper-media:$name is over 64 characters." >&2; exit 1
  fi
  count=$((count + 1))
done
[[ $count -gt 0 ]] || { echo "FATAL: no media/*/SKILL.md found." >&2; exit 1; }

fail=0
check() { # check <what> <jq filter that must print true>
  if [[ "$(jq -r "$2" "$OUT/plugin.json")" != "true" ]]; then
    echo "FATAL: plugin.json: $1" >&2; fail=1
  fi
}
I='.extensions["com.openai"].interface'
check "displayName must be 1 to 30 characters" "$I.displayName | (length >= 1 and length <= 30)"
check "displayName must not contain MCP or Plugin" "$I.displayName | test(\"mcp|plugin\"; \"i\") | not"
check "shortDescription must be 1 to 30 characters" "$I.shortDescription | (length >= 1 and length <= 30)"
check "longDescription must be 1 to 4000 characters" "$I.longDescription | (length >= 1 and length <= 4000)"
check "one to three starter prompts" "$I.defaultPrompt | (length >= 1 and length <= 3)"
check "a starter prompt is at most 128 characters" "$I.defaultPrompt | all(length <= 128)"
check "starter prompts must differ" "$I.defaultPrompt | (unique | length) == length"
check "the icon must be a file in the package" "[$I.composerIcon, $I.logo] | all(. == \"./assets/icon.png\")"
if [[ "$(jq -r '.mcpServers["opper-media"].url' "$OUT/mcp.json")" != "https://api.opper.ai/mcp/media-chatgpt" ]]; then
  echo "FATAL: mcp.json must point at https://api.opper.ai/mcp/media-chatgpt." >&2; fail=1
fi

# ChatGPT's rules keep money out of a listing and out of the conversation, and
# allow no comparison with other products. Nothing in the package is fetched
# from outside either.
FORBIDDEN='pric|cost|\$|credit|funds|wallet|top up|top-up|billing|purchase|upgrade|subscription|free trial|cheap|higgsfield|runway|skills\.opper\.ai|version-check'
while IFS= read -r -d '' f; do
  case "$f" in *.png) continue ;; esac
  if hits="$(grep -inE "$FORBIDDEN" "$f" | grep -v '"\$schema"')"; then
    echo "FATAL: $f has wording the ChatGPT package must not carry:" >&2
    echo "$hits" | cut -c1-160 >&2
    fail=1
  fi
done < <(find "$OUT" -type f -print0)
[[ $fail -eq 0 ]] || exit 1

echo "Built the ChatGPT plugin into $OUT/ with $count skills."
