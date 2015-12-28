NAME=clarity
ORG=aabs
CMD=/bin/bash
TAG=0.5

PODNAME=${ORG}-${NAME}-${TAG}


compile: build

build:
	docker build --rm -t "${ORG}/${NAME}:${TAG}" .

run: compile
	docker run  -d -p 80:3000 --name="${NAME}" ${ORG}/${NAME}:${TAG}

restart: stop clean-containers run

clean: stop clean-containers clean-images

stop:
	docker kill ${NAME}

clean-containers:
	docker ps -a | grep 'Exited' | awk '{print $$1}' | xargs docker rm

clean-images:
	docker images | grep "${NAME}" | awk '{print $$3}' | xargs docker rmi

deploy: save google-deploy

redeploy: google-undeploy deploy

google-push: build
	docker tag ${ORG}/${NAME}:${TAG} gcr.io/odoo-ba/${NAME}:${TAG}
	gcloud docker push gcr.io/odoo-ba/${NAME}:${TAG}
	# docker login -u aabs -e matthews.andrew@gmail.com tutum.co
	# docker tag -f ${ORG}/${NAME}:latest tutum.co/${ORG}/${NAME}
	# docker push tutum.co/${ORG}/${NAME}

save:
	git add -A
	git commit -m "further edits"
	git push github master

google-deploy: google-push
	kubectl run ${PODNAME} --image=gcr.io/odoo-ba/${NAME}:${TAG} --port=80
    kubectl expose rc ${PODNAME} --type="LoadBalancer"

google-undeploy: google-push
	# First, delete the Service, which also deletes your external load balancer:
	kubectl delete services ${PODNAME}
	# Delete the running pods with:
	kubectl delete rc ${PODNAME}
