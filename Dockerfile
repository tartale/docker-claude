FROM node:22-slim

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

# Rename the default 'node' user/group to 'claude'
RUN usermod -l claude -d /home/claude -m node && \
    groupmod -n claude node

WORKDIR /workspace
RUN chown claude:claude /workspace

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER claude

ENTRYPOINT ["entrypoint.sh"]
