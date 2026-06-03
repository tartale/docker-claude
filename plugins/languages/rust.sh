#!/usr/bin/env bash
set -euo pipefail

export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --no-modify-path --default-toolchain stable

# Symlink into /usr/local/bin so tools are available without PATH changes
ln -sf /usr/local/cargo/bin/cargo   /usr/local/bin/cargo
ln -sf /usr/local/cargo/bin/rustc   /usr/local/bin/rustc
ln -sf /usr/local/cargo/bin/rustup  /usr/local/bin/rustup
ln -sf /usr/local/cargo/bin/rustfmt /usr/local/bin/rustfmt
ln -sf /usr/local/cargo/bin/clippy-driver /usr/local/bin/clippy-driver
