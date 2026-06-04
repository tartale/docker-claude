#!/usr/bin/env bash
set -euo pipefail

plugins="${1:-}"
[ -z "$plugins" ] && exit 0

build_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.build"
mkdir -p "$build_dir"

if [ -d "$plugins" ]; then
    find "$plugins" -maxdepth 1 -name '*.sh' -exec cp {} "$build_dir/" \;
else
    cp "$plugins" "$build_dir/plugin.sh"
fi
