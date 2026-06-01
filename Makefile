DOCKER_IMAGE_TAG ?= local
DOCKER_IMAGE = tartale/claude-sandbox:$(DOCKER_IMAGE_TAG)

clean:
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true

image:
	@if docker buildx inspect multi-platform >/dev/null 2>&1 || \
	    docker buildx create --driver docker-container --use multi-platform >/dev/null 2>&1; then \
		docker buildx use multi-platform && \
		docker buildx build --platform linux/amd64,linux/arm64 --load -t $(DOCKER_IMAGE) .; \
	else \
		docker build -t $(DOCKER_IMAGE) .; \
	fi

pull:
	docker pull $(DOCKER_IMAGE)

push:
	docker push $(DOCKER_IMAGE)
	docker tag $(DOCKER_IMAGE) tartale/claude-sandbox:latest
	docker push tartale/claude-sandbox:latest

.PHONY: clean image pull push
