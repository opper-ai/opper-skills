#!/usr/bin/env bash
#
# Print metadata.version from a SKILL.md frontmatter (quotes stripped), or
# nothing if the skill has no version. Reads stdin when given "-", so CI can
# pipe in `git show <base>:<skill>/SKILL.md`.
#
# Usage:
#   scripts/skill-version.sh opper-api/SKILL.md
set -euo pipefail

awk '
  NR == 1 && /^---$/ { fm = 1; next }
  fm && /^---$/ { exit }
  fm && /^metadata:[[:space:]]*$/ { in_meta = 1; next }
  fm && in_meta && !/^  / { in_meta = 0 }
  fm && in_meta && /^  version:/ {
    sub(/^  version:[[:space:]]*/, ""); gsub(/["\047]/, ""); print; exit
  }
' "${1:--}"
