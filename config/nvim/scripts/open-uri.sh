#!/usr/bin/env bash
set -euo pipefail

uri="${1:-}"
if [[ -z "$uri" ]]; then
  echo "usage: open-uri.sh <uri>" >&2
  exit 1
fi

if command -v wslview >/dev/null 2>&1; then
  exec wslview "$uri"
fi

if command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "$uri"
fi

if command -v powershell.exe >/dev/null 2>&1; then
  esc_uri=${uri//\'/\'\'}
  exec powershell.exe -NoProfile -Command "Start-Process '$esc_uri'"
fi

echo "No opener found. Install wslview or xdg-open." >&2
exit 1
