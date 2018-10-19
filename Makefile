.PHONY: build-image run-local
IMAGE_TAG=picnichealth/split-me

build:
	docker build -t $(IMAGE_TAG) .

run-local:
	docker run --rm \
    --env FLASK_ENV=development \
    -p 5000:5000 \
    -v $$(dirname $$(pwd))/split-me/src:/src \
    $(IMAGE_TAG)
