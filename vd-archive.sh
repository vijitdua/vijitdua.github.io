#!/bin/sh
# Serve this archive on this computer, or swap in a newer ZIP.
# Run it from the unzipped folder:
#   sh vd-archive.sh serve
#   sh vd-archive.sh upgrade ~/Downloads/vijitdua-archive.zip
# The folder has to be the whole website. A host that puts it under an extra
# folder in the address cannot find the page files.
set -eu
cd "$(dirname "$0")"

usage() {
  echo "Usage:"
  echo "  sh vd-archive.sh serve              # open the archive on this computer"
  echo "  sh vd-archive.sh upgrade FILE.zip   # replace these files with a newer export"
  echo "Optional: PORT=8080"
  echo "Host the unzipped folder as the site root. This script does not upload it."
  exit 1
}

serve() {
  port="${PORT:-4173}"
  echo "This archive is at http://127.0.0.1:${port}/"
  echo "Leave this window open. Ctrl+C stops it."
  echo "Double-clicking index.html will not run the page scripts."
  echo "If you host this folder, it has to be the whole website, at the root of that host."
  if command -v python3 >/dev/null 2>&1; then
    exec python3 - "$port" <<'PY'
import json, os, sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
types = {}
if os.path.isfile("content-types.json"):
    with open("content-types.json", encoding="utf-8") as fh:
        types = json.load(fh)
class Handler(SimpleHTTPRequestHandler):
    def guess_type(self, file_path):
        rel = os.path.relpath(file_path, os.getcwd()).replace(os.sep, "/")
        meta = types.get(rel)
        self._vd_disposition = None
        if isinstance(meta, dict):
            self._vd_disposition = meta.get("disposition")
            return meta.get("type") or "application/octet-stream"
        if isinstance(meta, str):
            return meta
        guessed = super().guess_type(file_path)
        if isinstance(guessed, tuple):
            return guessed[0]
        return guessed
    def end_headers(self):
        disposition = getattr(self, "_vd_disposition", None)
        if disposition:
            self.send_header("Content-Disposition", disposition)
        super().end_headers()
ThreadingHTTPServer.allow_reuse_address = True
httpd = ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), Handler)
httpd.serve_forever()
PY
  fi
  if command -v python >/dev/null 2>&1; then
    exec python -m SimpleHTTPServer "$port"
  fi
  echo "Python is not installed. From this folder you can also run:"
  echo "  npx --yes serve -p ${port}"
  exit 1
}

extract_zip() {
  zipfile=$1
  dest=$2
  python3 - "$zipfile" "$dest" <<'PY'
import sys, zipfile
zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])
PY
}

upgrade() {
  zipfile=${1:-}
  if [ -z "$zipfile" ] || [ ! -f "$zipfile" ]; then
    echo "Pass the new ZIP from vijitdua.com/archive."
    echo "  sh vd-archive.sh upgrade ~/Downloads/vijitdua-archive.zip"
    exit 1
  fi
  if [ ! -f index.html ]; then
    echo "index.html is missing. Run this from the unzipped archive folder."
    exit 1
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "Python 3 is required to unpack the ZIP."
    exit 1
  fi
  tmp=$(mktemp -d)
  extract_zip "$zipfile" "$tmp"
  src=$tmp
  if [ ! -f "$src/index.html" ]; then
    only=$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 2)
    count=$(printf "%s\n" "$only" | grep -c . || true)
    if [ "$count" = "1" ] && [ -f "$only/index.html" ]; then
      src=$only
    else
      echo "That ZIP does not look like an archive (no index.html)."
      rm -rf "$tmp"
      exit 1
    fi
  fi
  find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  cp -R "$src"/. .
  rm -rf "$tmp"
  echo "Replaced the files in this folder. .git was left in place."
  echo "Serve it with: sh vd-archive.sh serve"
  echo "Uploading the folder is up to you. Keep it as the site root."
}

cmd=${1:-serve}
shift || true
case "$cmd" in
  serve) serve ;;
  upgrade) upgrade "$@" ;;
  *) usage ;;
esac
