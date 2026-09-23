#!/usr/bin/env bash
#
# Fail if a skill's files changed since <base> but its metadata.version did not.
# Installed copies only learn they are stale when the version moves, so every
# content change has to bump it (scripts/bump-version.sh <skill>).
#
# Usage:
#   scripts/check-versions.sh origin/main
set -euo pipefail

BASE="${1:?usage: $0 <base-ref>}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

errors=0
for f in */SKILL.md; do
  dir="${f%/SKILL.md}"
  if git diff --quiet "$BASE"...HEAD -- "$dir/"; then
    continue
  fi
  # A skill that is new in this change has nothing to compare against.
  if ! git cat-file -e "$BASE:$f" 2>/dev/null; then
    continue
  fi
  old="$(git show "$BASE:$f" | bash scripts/skill-version.sh -)"
  new="$(bash scripts/skill-version.sh "$f")"
  if [[ "$old" == "$new" ]]; then
    echo "ERROR: $dir changed but metadata.version is still '$new'. Run: scripts/bump-version.sh $dir"
    errors=$((errors + 1))
  else
    echo "$dir: ${old:-none} -> $new"
  fi
done

if [[ "$errors" -gt 0 ]]; then
  exit 1
fi
echo "Versions OK"
