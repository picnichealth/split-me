DOCKER_REGISTRY=localhost:15000
IMAGE_TAG=$(DOCKER_REGISTRY)/split-me:latest
NAMESPACE=split-me
SPLIT_ME_PORT=15001

.PHONY: build-image
build-image:
	docker build -t $(IMAGE_TAG) .

.PHONY: push-image
push-image:
	docker push $(IMAGE_TAG)

.PHONY: run-local
run-local: build-image
	docker run \
		--env FLASK_ENV=development \
		-p $(SPLIT_ME_PORT):$(SPLIT_ME_PORT) \
		--volume "$$(dirname $$(pwd))/split-me/src:/src" \
		$(IMAGE_TAG)

.PHONY: init
init:
	terraform init

.PHONY: deploy
deploy:
	terraform apply \
		-auto-approve \
		-var namespace=$(NAMESPACE)

.PHONY: launch-split-me
launch-split-me:
	kubectl port-forward deployment/split-me $(SPLIT_ME_PORT):$(SPLIT_ME_PORT) \
		--namespace=$(NAMESPACE) & \
		open http://localhost:15001; \
		wait

.PHONY: launch-prometheus
launch-prometheus:
	kubectl port-forward deployment/prometheus-server 15002:9090 \
		--namespace=$(NAMESPACE)-monitoring & \
		open http://localhost:15002; \
		wait

.PHONY: launch-grafana
launch-grafana:
	kubectl port-forward deployment/grafana 15003:3000 \
		--namespace=$(NAMESPACE)-monitoring & \
		open http://localhost:15003; \
		wait
