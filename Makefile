DOCKER_IMAGE_TAG ?= local
DOCKER_IMAGE = tartale/claude-sandbox:$(DOCKER_IMAGE_TAG)

clean:
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true

image:
	docker buildx build --builder multi-platform --platform linux/amd64,linux/arm64 --load -t $(DOCKER_IMAGE) .

pull:
	docker pull $(DOCKER_IMAGE)

push:
	docker push $(DOCKER_IMAGE)

.PHONY: clean image pull push
