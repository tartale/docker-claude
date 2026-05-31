#!/bin/bash
set -e

DOCKER_IMAGE="tartale/claude-sandbox:local"
CONTAINER_NAME="claude-sandbox-$(basename "$(pwd)")-$(openssl rand -hex 2)"
echo "Starting container: $CONTAINER_NAME"

docker run --rm \
    -v claude-home:/home/node \
    -v "$HOME/.claude.json:/tmp/.claude.json:ro" \
    -v "$HOME/.claude:/tmp/.claude:ro" \
    --entrypoint bash \
    "$DOCKER_IMAGE" -c 'cp /tmp/.claude.json /home/node/.claude.json && \
        rm -rf /home/node/.claude && \
        cd /tmp && tar --exclude=".git" -cf - .claude | tar -xf - -C /home/node/'

docker run -it --rm \
    --network=host \
    --name "$CONTAINER_NAME" \
    -e GITHUB_TOKEN \
    -v "$(pwd):/workspace" \
    -v claude-home:/home/node \
    "$DOCKER_IMAGE" "$@"
