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

## Environment variables

| Variable | Description |
|---|---|
| `DOCKER_IMAGE_TAG` | Tag of the `tartale/claude-sandbox` image to use (default: `latest`) |
| `GITHUB_TOKEN` | If set, configures Git inside the container to authenticate to GitHub using this token |

## License

MIT
