NAME=www
ORG=bizally
CMD=/bin/bash
SVCNAME=${ORG}${NAME}

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

deploy: save google-deploy

redeploy: google-undeploy deploy

google-push: build
	docker tag ${ORG}/${NAME} gcr.io/odoo-ba/${NAME}
	gcloud docker push gcr.io/odoo-ba/${NAME}

save:
	git add -A
	git commit -m "further edits"
	git push github master

google-deploy: google-push
	kubectl run ${SVCNAME} --image=gcr.io/odoo-ba/${NAME} --port=80
    kubectl expose rc ${SVCNAME} --type="LoadBalancer"

google-undeploy: google-push
	# First, delete the Service, which also deletes your external load balancer:
	kubectl delete services ${SVCNAME}
	# Delete the running pods with:
	kubectl delete rc ${SVCNAME}
