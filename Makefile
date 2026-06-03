DOCKER_IMAGE_TAG ?= local
DOCKER_IMAGE = tartale/claude-sandbox:$(DOCKER_IMAGE_TAG)

PLUGINS_ARG = $(if $(PLUGINS),--build-arg PLUGINS=$(PLUGINS))

clean:
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true

image:
	@if docker buildx inspect multi-platform >/dev/null 2>&1 || \
	    docker buildx create --driver docker-container --use multi-platform >/dev/null 2>&1; then \
		docker buildx use multi-platform && \
		docker buildx build --platform linux/amd64,linux/arm64 --push -t $(DOCKER_IMAGE) $(PLUGINS_ARG) .; \
	else \
		docker build -t $(DOCKER_IMAGE) $(PLUGINS_ARG) .; \
	fi

pull:
	docker pull $(DOCKER_IMAGE)

push:
	docker buildx build --platform linux/amd64,linux/arm64 --push \
	  -t $(DOCKER_IMAGE) -t tartale/claude-sandbox:latest $(PLUGINS_ARG) .

.PHONY: clean image pull push
