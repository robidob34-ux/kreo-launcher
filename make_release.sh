#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Kreo Launcher — release packager
# Copies your real launcher build into downloads/, computes the
# real file size + SHA-256, and rewrites index.html so the site
# serves the REAL file with a REAL checksum.
#
# Usage:
#   bash make_release.sh <path-to-build> <windows|macos|linux>
#
# Examples:
#   bash make_release.sh ~/builds/KreoLauncher-Setup-2.4.1.exe windows
#   bash make_release.sh ~/builds/KreoLauncher-2.4.1.dmg        macos
#   bash make_release.sh ~/builds/KreoLauncher-2.4.1.AppImage   linux
# ─────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")"

if [ $# -ne 2 ]; then
  echo "Usage: bash make_release.sh <path-to-build> <windows|macos|linux>"
  exit 1
fi

SRC="$1"
OS="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
[ -f "$SRC" ] || { echo "ERROR: file not found: $SRC"; exit 1; }

case "$OS" in
  windows) FILE="KreoLauncher-Setup-2.4.1.exe" ;;
  macos)   FILE="KreoLauncher-2.4.1.dmg"      ;;
  linux)   FILE="KreoLauncher-2.4.1.AppImage" ;;
  *) echo "ERROR: os must be windows, macos or linux"; exit 1 ;;
esac

mkdir -p downloads
cp "$SRC" "downloads/$FILE"

# Real size in MB and real SHA-256
if command -v sha256sum >/dev/null; then SHA=$(sha256sum "downloads/$FILE" | awk '{print $1}')
elif command -v shasum   >/dev/null; then SHA=$(shasum -a 256 "downloads/$FILE" | awk '{print $1}')
else echo "ERROR: need sha256sum or shasum installed"; exit 1; fi
SIZE=$(du -m "downloads/$FILE" | cut -f1)MB
echo ">> downloads/$FILE  ($SIZE, sha256 $SHA)"

python3 - "$OS" "$SHA" "$SIZE" <<'PY'
import re, sys
os_id, sha, size = sys.argv[1], sys.argv[2], sys.argv[3]
src = open('index.html').read()

# Rewrite the matching OS_OPTIONS entry in place
pattern = re.compile(
    r"\{ id:'" + re.escape(os_id) + r"', label:'[^']*', size:'[^']*', file:'[^']*', hash:'[^']*' \}"
)
replacement = {
    'windows': f"{{ id:'windows', label:'Windows', size:'{size}', file:'KreoLauncher-Setup-2.4.1.exe', hash:'{sha}' }}",
    'macos':   f"{{ id:'macos',   label:'macOS',   size:'{size}', file:'KreoLauncher-2.4.1.dmg',       hash:'{sha}' }}",
    'linux':   f"{{ id:'linux',   label:'Linux',   size:'{size}', file:'KreoLauncher-2.4.1.AppImage',  hash:'{sha}' }}",
}[os_id]
new, n = pattern.subn(replacement.replace('\\', '\\\\'), src)
if n != 1:
    sys.exit('ERROR: could not find the OS entry in index.html — is it unmodified?')
open('index.html', 'w').write(new)
print('>> index.html updated for', os_id)
PY

echo
echo "Done. Checksum + size embedded in index.html."
echo "Next: deploy the folder to GitHub Pages (see README.md)."
