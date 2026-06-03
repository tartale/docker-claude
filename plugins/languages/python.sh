#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y \
  python3-dev \
  python3-pip \
  python3-venv \
  pipx
rm -rf /var/lib/apt/lists/*

# uv: fast Python package/project manager
curl -fsSL https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh
