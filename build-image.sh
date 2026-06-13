#!/usr/bin/env bash
set -euo pipefail

REPO="tartale/claude-sandbox"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/refs/heads/${BRANCH}"

CS_IMAGE_TAG="${CS_IMAGE_TAG:-custom}"
CS_IMAGE="tartale/claude-sandbox:${CS_IMAGE_TAG}"
PLUGINS="${PLUGINS:-}"
LANGUAGE_VERSIONS="${LANGUAGE_VERSIONS:-}"
CLAUDE_VERSION="${CLAUDE_VERSION:-$(npm view @anthropic-ai/claude-code version 2>/dev/null || echo latest)}"

BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

echo "Fetching build files from ${REPO}@${BRANCH}..."

curl -fsSL "$RAW_BASE/Dockerfile"        > "$BUILD_DIR/Dockerfile"
curl -fsSL "$RAW_BASE/entrypoint.sh"     > "$BUILD_DIR/entrypoint.sh"

mkdir -p "$BUILD_DIR/plugins/languages"
curl -fsSL "$RAW_BASE/plugins/install.sh" > "$BUILD_DIR/plugins/install.sh"

# Always fetch built-in language plugins so custom plugins can compose them
for lang in cpp go java python2 python3 react ruby rust typescript; do
    curl -fsSL "$RAW_BASE/plugins/languages/${lang}.sh" \
        > "$BUILD_DIR/plugins/languages/${lang}.sh"
done

# Resolve PLUGINS to a path relative to BUILD_DIR
PLUGINS_ARG=""
if [ -n "$PLUGINS" ]; then
    if echo "$PLUGINS" | grep -qE '^https?://'; then
        # Remote URL — download into a subdirectory so PLUGINS_DIR resolves correctly
        mkdir -p "$BUILD_DIR/plugins/custom"
        curl -fsSL "$PLUGINS" > "$BUILD_DIR/plugins/custom/plugin.sh"
        PLUGINS_ARG="plugins/custom/plugin.sh"
    elif [ -d "$PLUGINS" ]; then
        # Local directory — copy all .sh files into custom/
        mkdir -p "$BUILD_DIR/plugins/custom"
        find "$PLUGINS" -maxdepth 1 -name '*.sh' -exec cp {} "$BUILD_DIR/plugins/custom/" \;
        PLUGINS_ARG="plugins/custom"
    elif [ -f "$PLUGINS" ]; then
        # Local file
        mkdir -p "$BUILD_DIR/plugins/custom"
        cp "$PLUGINS" "$BUILD_DIR/plugins/custom/plugin.sh"
        PLUGINS_ARG="plugins/custom/plugin.sh"
    else
        # Built-in plugin name (e.g. "python3", "go")
        if [ ! -f "$BUILD_DIR/plugins/languages/${PLUGINS}.sh" ]; then
            echo "Unknown plugin: ${PLUGINS}" >&2
            echo "Available built-ins: cpp go java python2 python3 react ruby rust typescript" >&2
            exit 1
        fi
        PLUGINS_ARG="plugins/languages/${PLUGINS}.sh"
    fi
fi

BUILD_ARGS=(
    -t "$CS_IMAGE"
    --build-arg "CLAUDE_VERSION=$CLAUDE_VERSION"
)
[ -n "$PLUGINS_ARG" ]        && BUILD_ARGS+=(--build-arg "PLUGINS=$PLUGINS_ARG")
[ -n "$LANGUAGE_VERSIONS" ]  && BUILD_ARGS+=(--build-arg "LANGUAGE_VERSIONS=$LANGUAGE_VERSIONS")

echo "Building ${CS_IMAGE}..."
docker build "${BUILD_ARGS[@]}" "$BUILD_DIR"
echo "Done. Image built: ${CS_IMAGE}"
