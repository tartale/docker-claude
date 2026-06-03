# claude-sandbox

Runs [Claude Code](https://github.com/anthropics/claude-code) in a Docker container, mounting your current directory as the workspace. This gives Claude a sandboxed environment to read and modify files without touching the rest of your system.

Your Claude credentials (`~/.claude` and `~/.claude.json`) are bind-mounted into the container so you stay logged in.

The container runs as a user matching your host UID and GID, so files written to the workspace are owned by you. Your shell's umask is also applied inside the container so new files get the expected permissions. Note that on macOS, Docker Desktop runs containers in a Linux VM, so the host umask has no effect — the default umask of the container will be used instead.

## Requirements

- Docker
- An Anthropic account with Claude Code access

## Usage

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tartale/claude-sandbox/refs/heads/main/claude-sandbox.sh)"
```

Run this from any project directory. Claude Code will start inside a container with that directory as `/workspace`.

Any arguments are passed through to `claude`.

## Plugins

Plugins are shell scripts that install additional tools into the sandbox. The `plugins/` directory contains ready-made language packs:

| Plugin | Installs |
|---|---|
| `plugins/languages/cpp.sh` | `build-essential`, `clang`, `cmake`, `gdb`, `ninja`, `valgrind` |
| `plugins/languages/go.sh` | Latest stable Go toolchain |
| `plugins/languages/java.sh` | OpenJDK 21, Maven |
| `plugins/languages/python.sh` | `pip`, `venv`, `pipx`, `uv` |
| `plugins/languages/ruby.sh` | Ruby, Bundler |
| `plugins/languages/rust.sh` | Rust stable via rustup (`cargo`, `rustc`, `rustfmt`, `clippy`) |

### Using a single plugin

Pass the path to a script as `PLUGINS` when building the image:

```bash
PLUGINS=plugins/languages/go.sh DOCKER_IMAGE_TAG=my-tag make image
```

### Using multiple plugins

Pass a directory of `.sh` scripts to run all of them, in alphabetical order:

```bash
PLUGINS=plugins/languages DOCKER_IMAGE_TAG=my-tag make image
```

Prefix filenames with numbers to control order when it matters (`01-go.sh`, `02-rust.sh`, …).

### Writing your own plugin

A plugin is any executable shell script. Create one anywhere and point `PLUGINS` at it:

```bash
#!/usr/bin/env bash
set -euo pipefail
apt-get update && apt-get install -y my-tool && rm -rf /var/lib/apt/lists/*
```

The script runs as root during `docker build`, so standard `apt-get` installs work without `sudo`. Make sure the file is executable (`chmod +x`) before building.

### Runtime plugins

`PLUGINS` also works at runtime with `claude-sandbox.sh`. The script (or directory) is bind-mounted into the container and executed before Claude starts, letting you run setup steps without rebuilding the image:

```bash
PLUGINS=plugins/languages/python.sh ./claude-sandbox.sh
```

## Environment variables

| Variable | Description |
|---|---|
| `DOCKER_IMAGE_TAG` | Tag of the `tartale/claude-sandbox` image to use (default: `latest`) |
| `GITHUB_TOKEN` | If set, configures Git inside the container to authenticate to GitHub using this token |
| `PLUGINS` | Path to a plugin script or directory of plugin scripts to install |

## License

MIT
