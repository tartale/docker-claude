#!/usr/bin/env bash
set -euo pipefail

JAVA_VERSION=$(echo "${LANGUAGE_VERSIONS:-}" | tr ' ' '\n' | grep '^java-' | head -1 | sed 's/java-//')
JAVA_MAJOR="${JAVA_VERSION%%.*}"

apt-get update
apt-get install -y \
  "openjdk-${JAVA_MAJOR:-21}-jdk" \
  maven
rm -rf /var/lib/apt/lists/*
