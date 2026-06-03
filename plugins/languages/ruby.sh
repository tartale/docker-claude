#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y \
  ruby \
  ruby-dev
rm -rf /var/lib/apt/lists/*

gem install bundler
