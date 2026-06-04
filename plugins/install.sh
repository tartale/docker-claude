#!/usr/bin/env bash
set -euo pipefail

target="$1"
export PLUGINS_DIR="$(cd "$(dirname "$target")/.." && pwd)"

if [ -d "$target" ]; then
    find "$target" -maxdepth 1 -name '*.sh' | sort | while IFS= read -r f; do
        bash "$f"
    done
else
    bash "$target"
fi
