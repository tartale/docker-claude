FROM node:22-slim

RUN apt-get update \
 && apt-get install -y ca-certificates curl \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y \
      doas \
      gh \
      git \
      git-lfs \
      jq \
      less \
      make \
      openssh-client \
      procps \
      python3 \
      ripgrep \
      tree \
      unzip \
      vim \
      wget \
      zip \
 && rm -rf /var/lib/apt/lists/*

ARG CLAUDE_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_VERSION}

# Rename the default 'node' user/group to 'claude'
RUN usermod -l claude -d /home/claude -m node \
 && groupmod -n claude node

WORKDIR /workspace
RUN chown claude:claude /workspace

COPY plugins/install.sh /usr/local/bin/install-plugins.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ARG LANG_VERSION=""
ARG PLUGINS=""
RUN --mount=type=bind,target=/build \
    if [ -n "$PLUGINS" ]; then \
        install-plugins.sh "/build/$PLUGINS"; \
    fi

ENV CUID=1000
ENV CGID=1000
ENV CMASK=0002

ENTRYPOINT ["entrypoint.sh"]
