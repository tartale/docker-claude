FROM node:22-slim

RUN apt-get update && apt-get install -y \
  doas \
  git \
  curl \
  ca-certificates \
&& rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

# Rename the default 'node' user/group to 'claude'
RUN usermod -l claude -d /home/claude -m node \
 && groupmod -n claude node

WORKDIR /workspace
RUN chown claude:claude /workspace

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV GITHUB_TOKEN=""
ENV CUID=1000
ENV CGID=1000
ENV CMASK=0002

ENTRYPOINT ["entrypoint.sh"]
