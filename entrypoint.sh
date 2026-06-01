#!/bin/bash
set -e

usermod -u "${UID}" claude >/dev/null 2>&1 || true
groupmod -g "${GID}" claude >/dev/null 2>&1 || true

su claude -c -m start.sh
