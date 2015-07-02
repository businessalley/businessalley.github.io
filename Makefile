DOCKER_IMAGE_VERSION=0.1.0
DOCKER_IMAGE_NAME=aabs/clarity
DOCKER_IMAGE_TAGNAME=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

default: build

build:
	docker build -t $(DOCKER_IMAGE_TAGNAME) .
	docker tag -f $(DOCKER_IMAGE_TAGNAME) $(DOCKER_IMAGE_NAME):latest

push:
	docker push $(DOCKER_IMAGE_NAME)

run:
	docker run -d -p 81:80 -d $(DOCKER_IMAGE_TAGNAME)
