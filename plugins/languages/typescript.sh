#!/usr/bin/env bash
set -euo pipefail

TS_VERSION=$(echo "${LANG_VERSION:-}" | tr ' ' '\n' | grep '^typescript-' | head -1 | sed 's/typescript-//')

npm install -g \
  "typescript${TS_VERSION:+@$TS_VERSION}" \
  ts-node \
  tsx \
  @types/node
