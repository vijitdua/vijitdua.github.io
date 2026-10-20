#!/bin/sh
set -eu
cd "$(dirname "$0")"
zip=${1:?Pass the path to the archive zip.}
[ -f "$zip" ] || { echo "ZIP not found."; exit 1; }

work=$(mktemp -d)
python3 - "$zip" "$work" <<'PY'
import sys
import zipfile
from pathlib import Path

dest = Path(sys.argv[2]).resolve()
limit = 100_000_000
with zipfile.ZipFile(sys.argv[1]) as zf:
    for info in zf.infolist():
        raw = info.filename.replace("\\", "/")
        if raw.startswith("/") or raw.startswith("../") or "/../" in ("/" + raw) or raw == "..":
            raise SystemExit("ZIP member has an unsafe path.")
        target = (dest / raw).resolve()
        if target != dest and dest not in target.parents:
            raise SystemExit("ZIP member escapes the destination.")
        if info.file_size > limit:
            raise SystemExit("One file inside the ZIP is over 100MB. GitHub will reject it: " + raw)
    zf.extractall(dest)
PY

src=$work
if [ ! -f "$src/index.html" ]; then
  n=$(find "$work" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
  nested=$(find "$work" -mindepth 1 -maxdepth 1 -type d)
  if [ "$n" -eq 1 ] && [ -f "$nested/index.html" ]; then
    src=$nested
  else
    echo "ZIP has no index.html at its root."
    exit 1
  fi
fi

keep=$(mktemp -d)
cp -a "$0" "$keep/publish.sh"
[ -d .github ] && cp -a .github "$keep/.github"
[ -f CNAME ] && cp -a CNAME "$keep/CNAME"
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -a "$src"/. .
cp -a "$keep/publish.sh" ./publish.sh
chmod +x ./publish.sh
[ -d "$keep/.github" ] && { rm -rf .github; cp -a "$keep/.github" .github; }
[ -f "$keep/CNAME" ] && cp -a "$keep/CNAME" CNAME
touch .nojekyll

git checkout --orphan vd-archive-one
git add -A
git commit -m "vijitdua.com archive"
git branch -M main
git push --force origin main
echo "Pushed. https://vijitdua.github.io/ updates after Pages rebuilds."
