#!/usr/bin/env bash
#
# Bump the version of one or more skills to today's date (UTC).
#
# A skill's version lives in two places that must agree:
#   - metadata.version in the SKILL.md frontmatter (read by versions.json and CI)
#   - the version-check block right after the frontmatter (read by agents)
# This script rewrites both, and inserts the block if a skill has none yet.
# A second bump on the same day becomes YYYY-MM-DD.2, then .3, and so on.
#
# Usage:
#   scripts/bump-version.sh opper-api opper-sdks
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <skill-dir>..." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY="$(date -u +%Y-%m-%d)"

for arg in "$@"; do
  skill="${arg%/}"
  file="$REPO_ROOT/$skill/SKILL.md"
  if [[ ! -f "$file" ]]; then
    echo "FATAL: $skill/SKILL.md not found" >&2
    exit 1
  fi

  current="$(bash "$REPO_ROOT/scripts/skill-version.sh" "$file")"
  if [[ "$current" == "$TODAY" ]]; then
    next="$TODAY.2"
  elif [[ "$current" == "$TODAY".* ]]; then
    next="$TODAY.$(( ${current##*.} + 1 ))"
  else
    next="$TODAY"
  fi

  tmp="$(mktemp)"
  awk -v name="$skill" -v ver="$next" '
    function block() {
      print "<!-- version-check: removed from the copy served at skills.opper.ai -->"
      print "> **Skill version " ver ".** This is a locally installed copy and may be out of date. Once per session, fetch https://skills.opper.ai/versions.json and compare its `\"" name "\"` entry with " ver ". If they differ, read https://skills.opper.ai/" name "/SKILL.md and follow that instead of this copy for the rest of the session, and tell the user once that their installed Opper skills are out of date (update with `npx skills update`, or `git pull` in a manual clone). Do not edit the installed files. If the fetch fails, continue with this copy."
      print "<!-- /version-check -->"
    }
    # Frontmatter: set metadata.version, adding the metadata map if missing.
    NR == 1 && /^---$/ { fm = 1; print; next }
    fm && /^metadata:[[:space:]]*$/ { print; print "  version: \"" ver "\""; in_meta = 1; wrote = 1; next }
    fm && in_meta && /^  version:/ { next }
    fm && in_meta && !/^  / { in_meta = 0 }
    fm && /^---$/ {
      if (!wrote) { print "metadata:"; print "  version: \"" ver "\"" }
      print; print ""; block()
      fm = 0; lead = 1; next
    }
    fm { print; next }
    # Body: drop any existing block (it was just rewritten above), then keep
    # exactly one blank line before the rest of the body.
    /^<!-- version-check/ { skipping = 1; next }
    skipping { if ($0 ~ /^<!-- \/version-check -->/) skipping = 0; next }
    lead && $0 == "" { next }
    lead { print ""; lead = 0 }
    { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
  echo "$skill: ${current:-none} -> $next"
done
