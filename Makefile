CS_IMAGE_TAG ?= local
CS_IMAGE = tartale/claude-sandbox:$(CS_IMAGE_TAG)
REGISTRY = tartale/claude-sandbox

PLUGINS_ARG = $(if $(PLUGINS),--build-arg PLUGINS=$(PLUGINS))
LANGUAGE_VERSIONS_ARG = $(if $(LANGUAGE_VERSIONS),--build-arg LANGUAGE_VERSIONS=$(LANGUAGE_VERSIONS))
LANGUAGES = $(patsubst plugins/languages/%.sh,%,$(wildcard plugins/languages/*.sh))
CLAUDE_VERSION ?= $(shell npm view @anthropic-ai/claude-code version 2>/dev/null || echo latest)
CLAUDE_VERSION_ARG = --build-arg CLAUDE_VERSION=$(CLAUDE_VERSION)

clean:
	docker rmi $(CS_IMAGE) 2>/dev/null || true

image:
	@if docker buildx inspect multi-platform >/dev/null 2>&1 || \
	    docker buildx create --driver docker-container --use multi-platform >/dev/null 2>&1; then \
		docker buildx use multi-platform && \
		docker buildx build --load -t $(CS_IMAGE) $(PLUGINS_ARG) $(LANGUAGE_VERSIONS_ARG) $(CLAUDE_VERSION_ARG) .; \
	else \
		docker build -t $(CS_IMAGE) $(PLUGINS_ARG) $(LANGUAGE_VERSIONS_ARG) $(CLAUDE_VERSION_ARG) .; \
	fi

pull:
	docker pull $(CS_IMAGE)

push:
	docker buildx build --platform linux/amd64,linux/arm64 --push \
	  -t $(CS_IMAGE) -t tartale/claude-sandbox:latest $(PLUGINS_ARG) $(LANGUAGE_VERSIONS_ARG) $(CLAUDE_VERSION_ARG) .

all: push
	@for lang in $(LANGUAGES); do \
		echo "Building tartale/claude-sandbox:$$lang..."; \
		docker buildx build --platform linux/amd64,linux/arm64 --push \
		  -t tartale/claude-sandbox:$$lang \
		  --build-arg PLUGINS=plugins/languages/$$lang.sh $(CLAUDE_VERSION_ARG) .; \
	done

tags: tags-base tags-languages

tags-base:
	./tag-images.sh base

tags-languages:
	./tag-images.sh languages

.PHONY: all clean image pull push tags tags-base tags-languages
