#!/usr/bin/env bash
set -euo pipefail

target="$1"

if [ -d "$target" ]; then
    export PLUGINS_DIR="$(cd "$target/.." && pwd)"
    find "$target" -maxdepth 1 -name '*.sh' | sort | while IFS= read -r f; do
        bash "$f"
    done
else
    export PLUGINS_DIR="$(cd "$(dirname "$target")/.." && pwd)"
    bash "$target"
fi
