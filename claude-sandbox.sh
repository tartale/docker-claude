#!/usr/bin/env bash
set -e

DOCKER_IMAGE="tartale/claude-sandbox:local"
CONTAINER_NAME="claude-sandbox-$(basename "$(pwd)")-$(openssl rand -hex 2)"
echo "Starting container: $CONTAINER_NAME"

case "$(uname -m)" in
  x86_64)  PLATFORM="linux/amd64" ;;
  aarch64) PLATFORM="linux/arm64" ;;
  *)       PLATFORM="linux/$(uname -m)" ;;
esac

# Ensure credential files exist before bind-mounting (Docker creates a
# directory instead of a file if the source path is absent).
touch "$HOME/.claude.json"
mkdir -p "$HOME/.claude"

# Allow the container's claude user (UID 1000) to write to host-owned files by
# adding the host user's GID as a supplementary group, and making the
# credential files group-writable. The setgid bit on .claude/ ensures new
# files created inside inherit the group rather than the container's default.
chmod g+rw "$HOME/.claude.json" 2>/dev/null || true
chmod g+rw "$HOME/.claude" 2>/dev/null || true
chmod g+s "$HOME/.claude" 2>/dev/null || true

docker run -it --rm \
  --platform "$PLATFORM" \
  --network=host \
  --name "$CONTAINER_NAME" \
  --group-add "$(id -g)" \
  -e GITHUB_TOKEN \
  -v "$(pwd):/workspace" \
  -v "$HOME/.claude.json:/home/claude/.claude.json" \
  -v "$HOME/.claude:/home/claude/.claude" \
  "$DOCKER_IMAGE" "$@"
