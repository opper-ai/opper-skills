#!/usr/bin/env bash
#
# Build the static site for skills.opper.ai.
#
# Walks every <skill>/SKILL.md and guides/<guide>/SKILL.md, validates its YAML frontmatter, copies each
# skill folder (SKILL.md + references/) into _site/ with the local-only
# version-check block removed, writes _site/versions.json (skill name ->
# metadata.version), and copies the router (opper/SKILL.md) to _site/index.md
# so curl https://skills.opper.ai/ returns the router content.
#
# Deliberately dumb on purpose: no eval, no executing repo content, only
# cp/find/grep/awk. See CONTRIBUTING.md / safety design for why.
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
for f in */SKILL.md guides/*/SKILL.md; do
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

# The version-check block tells a locally installed copy to compare itself
# with the live one. The live copy is the latest by definition, so the block
# is removed from what we serve.
strip_version_check() {
  awk '
    /^<!-- version-check/ { skipping = 1; next }
    skipping { if ($0 ~ /^<!-- \/version-check -->/) { skipping = 0; drop_blank = 1 } next }
    drop_blank && $0 == "" { drop_blank = 0; next }
    { drop_blank = 0; print }
  ' "$1"
}

# Same parsing as scripts/skill-version.sh, inlined so this script runs
# nothing else from the repo.
skill_version() {
  awk '
    NR == 1 && /^---$/ { fm = 1; next }
    fm && /^---$/ { exit }
    fm && /^metadata:[[:space:]]*$/ { in_meta = 1; next }
    fm && in_meta && !/^  / { in_meta = 0 }
    fm && in_meta && /^  version:/ {
      sub(/^  version:[[:space:]]*/, ""); gsub(/["\047]/, ""); print; exit
    }
  ' "$1"
}

VERSIONS="{"
sep=""
for f in "${SKILLS[@]}"; do
  dir="${f%/SKILL.md}"
  mkdir -p "$OUT/$dir"
  strip_version_check "$f" > "$OUT/$dir/SKILL.md"
  if grep -q 'version-check' "$OUT/$dir/SKILL.md"; then
    echo "FATAL: $f has an unterminated version-check block." >&2
    exit 1
  fi
  if [[ -d "$dir/references" ]]; then
    cp -R "$dir/references" "$OUT/$dir/references"
  fi
  VERSIONS+="$sep\"$dir\": \"$(skill_version "$f")\""
  sep=", "
done

# 3. versions.json: what a local copy compares its own version against.
echo "$VERSIONS}" > "$OUT/versions.json"

# 4. Router becomes the site root so `curl https://skills.opper.ai/` works.
cp "$OUT/$ROUTER" "$OUT/index.md"

# 5. Minimal 404 (referenced by the CloudFront distribution).
cat > "$OUT/404.html" <<'EOF'
<!doctype html>
<title>404 — skills.opper.ai</title>
<h1>404 — Not Found</h1>
<p>This path doesn't exist. Start at <a href="/">/</a> for the skill index.</p>
EOF

echo
echo "Built $(find "$OUT" -type f | wc -l | tr -d ' ') files into $OUT/"
