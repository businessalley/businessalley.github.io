NAME=clarity
ORG=aabs
CMD=/bin/bash

compile: build

build:
	docker build --rm -t "${ORG}/${NAME}" .

run: compile
	docker run  -d -p 80:3000 --name="${NAME}" ${ORG}/${NAME}

restart: stop clean-containers run

clean: stop clean-containers clean-images

stop:
	docker kill ${NAME}

clean-containers:
	docker ps -a | grep 'Exited' | awk '{print $$1}' | xargs docker rm

clean-images:
	docker images | grep "${NAME}" | awk '{print $$3}' | xargs docker rmi

deploy:
	git add -A
	git commit -m "further edits"
	git push github master

tutum-push: build
	docker login -u aabs -e matthews.andrew@gmail.com tutum.co
	docker tag -f ${ORG}/${NAME}:latest tutum.co/${ORG}/${NAME}
	docker push tutum.co/${ORG}/${NAME}
