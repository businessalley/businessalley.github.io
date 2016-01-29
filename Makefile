all: deploy

deploy: save
	git push origin master

save:
	git add -A
	git commit -m "further edits"

sync:
	git pull origin master
