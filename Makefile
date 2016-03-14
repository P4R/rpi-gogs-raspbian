IMAGENAME := $(shell basename `git rev-parse --show-toplevel`)
SHA := $(shell git rev-parse --short HEAD)
timestamp := $(shell date +"%Y%m%d%H%M")
GOGS_VERSION := 0.9.0

default: docker

download_gogs:
	curl -L https://github.com/gogits/gogs/releases/download/v$(GOGS_VERSION)/raspi2.zip > raspi2.zip
	unzip -oq raspi2.zip
	ls -la gogs/

dockerbuild:
	docker rmi -f $(IMAGENAME):bak || true
	docker tag $(IMAGENAME) $(IMAGENAME):bak || true
	docker rmi -f $(IMAGENAME) || true
	docker build -t $(IMAGENAME) .

testimg:
	docker rm -f new-$(IMAGENAME) || true
	docker run -d --name new-$(IMAGENAME) $(IMAGENAME):latest
	docker inspect -f '{{.NetworkSettings.IPAddress}}' new-$(IMAGENAME)
	docker logs -f new-$(IMAGENAME)

docker: download_gogs dockerbuild
