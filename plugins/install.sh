#!/usr/bin/env bash
set -euo pipefail

target="$1"

if [ -d "$target" ]; then
    PLUGINS_DIR="$(cd "$target/.." && pwd)"
    export PLUGINS_DIR
    find "$target" -maxdepth 1 -name '*.sh' | sort | while IFS= read -r f; do
        bash "$f"
    done
else
    PLUGINS_DIR="$(cd "$(dirname "$target")/.." && pwd)"
    export PLUGINS_DIR
    bash "$target"
fi
