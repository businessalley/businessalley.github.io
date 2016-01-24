NAME=www
ORG=bizally
CMD=/bin/bash
SVCNAME=${ORG}${NAME}
PROJECTID=odoo-ba

all: redeploy

build:
	docker build --rm -t "${ORG}/${NAME}" .

run: build
	docker run  -d -p 80:80 --name="${NAME}" ${ORG}/${NAME}

restart: stop clean-containers run

clean: stop clean-containers clean-images

stop:
	docker kill ${NAME}

clean-containers:
	docker ps -a | grep 'Exited' | awk '{print $$1}' | xargs docker rm

clean-images:
	docker images | grep "${NAME}" | awk '{print $$3}' | xargs docker rmi

deploy: google-deploy

redeploy-no-push: google-undeploy google-deploy-no-push
redeploy: google-undeploy google-deploy

google-push: build
	docker tag -f ${ORG}/${NAME} gcr.io/${PROJECTID}/${NAME}
	# gcloud docker rmi gcr.io/${PROJECTID}/${NAME}
	gcloud docker push gcr.io/${PROJECTID}/${NAME}

save:
	git add -A
	git commit -m "further edits"
	git push github master

google-deploy-no-push:
	kubectl run ${SVCNAME} --image=gcr.io/${PROJECTID}/${NAME} --port=80
	kubectl expose rc ${SVCNAME} --type="LoadBalancer"

google-deploy: google-push
	kubectl run ${SVCNAME} --image=gcr.io/${PROJECTID}/${NAME} --port=80
	kubectl expose rc ${SVCNAME} --type="LoadBalancer"
	#
	#
	# SLEEPING for 5 minutes to give google time to start load balancer and containers
	# ================================================================================
	sleep 300
	#
	#
	# Getting the external IP address to use for the domain registrar CNAME
	# =====================================================================
	kubectl get svc ${SVCNAME} -o json | jq '.status.loadBalancer.ingress[0].ip'

google-undeploy:
	# First, delete the Service, which also deletes your external load balancer:
	kubectl delete services ${SVCNAME} --ignore-not-found=true
	# Delete the running pods with:
	kubectl delete rc ${SVCNAME} --ignore-not-found=true
	kubectl delete po ${SVCNAME} --ignore-not-found=true
	
