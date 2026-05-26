#!/usr/bin/env bash
#
# Build the static site for skills.opper.ai.
#
# Walks every <skill>/SKILL.md, validates its YAML frontmatter, copies each
# skill folder (SKILL.md + references/) into _site/, and copies the router
# (opper/SKILL.md) to _site/index.md so curl https://skills.opper.ai/ returns
# the router content.
#
# Deliberately dumb on purpose: no eval, no executing repo content, only
# cp/find/grep. See CONTRIBUTING.md / safety design for why.
#
# Usage:
#   scripts/build-site.sh             # build into ./_site
#   scripts/build-site.sh --dry-run   # validate + report file count; don't write
set -euo pipefail

DRY=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY="1"
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUT="_site"
ROUTER="opper/SKILL.md"

if [[ ! -f "$ROUTER" ]]; then
  echo "FATAL: $ROUTER not found — the router skill is required." >&2
  exit 1
fi

# 1. Validate every <skill>/SKILL.md has YAML frontmatter with name + description.
shopt -s nullglob
SKILLS=()
for f in */SKILL.md; do
  SKILLS+=("$f")
  if ! head -1 "$f" | grep -qx -- '---'; then
    echo "FATAL: $f is missing leading '---' frontmatter delimiter." >&2
    exit 1
  fi
  # Look for name: and description: inside the first frontmatter block
  # (between the first '---' and the second '---').
  awk '
    NR == 1 && /^---$/ { in_fm = 1; next }
    in_fm && /^---$/   { exit }
    in_fm && /^name:/        { saw_name = 1 }
    in_fm && /^description:/ { saw_desc = 1 }
    END { exit !(saw_name && saw_desc) }
  ' "$f" || { echo "FATAL: $f frontmatter must include both name: and description:" >&2; exit 1; }
done

if [[ ${#SKILLS[@]} -eq 0 ]]; then
  echo "FATAL: no <skill>/SKILL.md files found." >&2
  exit 1
fi

echo "Validated ${#SKILLS[@]} skills:"
printf '  - %s\n' "${SKILLS[@]}"

if [[ -n "$DRY" ]]; then
  echo "Dry run OK — not writing $OUT/"
  exit 0
fi

# 2. Build _site/.
rm -rf "$OUT"
mkdir -p "$OUT"

for f in "${SKILLS[@]}"; do
  dir="${f%/SKILL.md}"
  mkdir -p "$OUT/$dir"
  cp "$f" "$OUT/$dir/SKILL.md"
  if [[ -d "$dir/references" ]]; then
    cp -R "$dir/references" "$OUT/$dir/references"
  fi
done

# 3. Router becomes the site root so `curl https://skills.opper.ai/` works.
cp "$ROUTER" "$OUT/index.md"

# 4. Minimal 404 (referenced by the CloudFront distribution).
cat > "$OUT/404.html" <<'EOF'
<!doctype html>
<title>404 — skills.opper.ai</title>
<h1>404 — Not Found</h1>
<p>This path doesn't exist. Start at <a href="/">/</a> for the skill index.</p>
EOF

echo
echo "Built $(find "$OUT" -type f | wc -l | tr -d ' ') files into $OUT/"
