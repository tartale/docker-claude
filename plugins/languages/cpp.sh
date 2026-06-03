#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y \
  build-essential \
  clang \
  clang-format \
  clang-tidy \
  cmake \
  gdb \
  ninja-build \
  pkg-config \
  valgrind
rm -rf /var/lib/apt/lists/*
