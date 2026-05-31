MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOCKER_IMAGE_TAG ?= local
DOCKER_IMAGE = tartale/claude-sandbox:$(DOCKER_IMAGE_TAG)
UNIQUE_ID := $(shell openssl rand -hex 2)
DOCKER_CONTAINER_NAME = claude-sandbox-$(notdir $(patsubst %/,%,$(MAKEFILE_DIR)))-$(UNIQUE_ID)
DOCKER_RUN_ARGS = --rm --network=host --name $(DOCKER_CONTAINER_NAME) \
  -e GITHUB_TOKEN \
  -v $(MAKEFILE_DIR):/workspace \
  -v claude-home:/home/node

clean:
	docker kill $(DOCKER_CONTAINER_NAME) 2>/dev/null || true
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true
	docker volume rm claude-home 2>/dev/null || true

image:
	docker build -t $(DOCKER_IMAGE) .

login:
	docker run --rm \
		-v claude-home:/home/node \
		-v $(HOME)/.claude.json:/tmp/.claude.json:ro \
		-v $(HOME)/.claude:/tmp/.claude:ro \
		--entrypoint bash \
		$(DOCKER_IMAGE) -c 'cp /tmp/.claude.json /home/node/.claude.json && \
			rm -rf /home/node/.claude && \
			cd /tmp && tar --exclude=".git" -cf - .claude | tar -xf - -C /home/node/'

run:
	docker run -it $(DOCKER_RUN_ARGS) $(DOCKER_IMAGE)

run-bg:
	docker run -d $(DOCKER_RUN_ARGS) $(DOCKER_IMAGE)

push:
	docker buildx inspect multi-platform >/dev/null 2>&1 || docker buildx create --name multi-platform --driver docker-container --use
	docker buildx build --builder multi-platform --platform linux/amd64,linux/arm64 -t $(DOCKER_IMAGE) --push .

shell:
	docker run -it $(DOCKER_RUN_ARGS) $(DOCKER_IMAGE) /bin/bash

.PHONY: clean image login run run-bg push shell
