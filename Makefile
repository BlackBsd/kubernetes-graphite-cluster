DOCKER_REPOSITORY?=nanit
SUDO?=sudo

STATSD_PROXY_APP_NAME=statsd
STATSD_PROXY_DIR_NAME=statsd-proxy
STATSD_PROXY_DOCKER_DIR=docker/$(STATSD_PROXY_DIR_NAME)
STATSD_PROXY_IMAGE_TAG=$(shell git log -n 1 --pretty=format:%h $(STATSD_PROXY_DOCKER_DIR))
STATSD_PROXY_IMAGE_NAME=$(DOCKER_REPOSITORY)/$(STATSD_PROXY_APP_NAME):$(STATSD_PROXY_IMAGE_TAG)
STATSD_PROXY_REPLICAS?=$(shell curl -s config/$(NANIT_ENV)/$(STATSD_PROXY_APP_NAME)/replicas)

define generate-statsd-proxy-svc
	sed -e 's/{{APP_NAME}}/$(STATSD_PROXY_APP_NAME)/g' kube/$(STATSD_PROXY_DIR_NAME)/svc.yml
endef

define generate-statsd-proxy-dep
	if [ -z "$(STATSD_PROXY_REPLICAS)" ]; then echo "ERROR: STATSD_PROXY_REPLICAS is empty!"; exit 1; fi
	sed -e 's/{{APP_NAME}}/$(STATSD_PROXY_APP_NAME)/g;s,{{IMAGE_NAME}},$(STATSD_PROXY_IMAGE_NAME),g;s/{{REPLICAS}}/$(STATSD_PROXY_REPLICAS)/g' kube/$(STATSD_PROXY_DIR_NAME)/dep.yml
endef

undeploy-statsd-proxy:
	$(call generate-statsd-proxy-dep) | kubectl delete -f - && $(call generate-statsd-proxy-svc) | kubectl delete -f -

deploy-statsd-proxy: docker-statsd-proxy
	kubectl get svc $(STATSD_PROXY_APP_NAME) || $(call generate-statsd-proxy-svc) | kubectl create -f -
	$(call generate-statsd-proxy-dep) | kubectl apply -f -

docker-statsd-proxy:
	$(SUDO) docker pull $(STATSD_PROXY_IMAGE_NAME) || ($(SUDO) docker build -t $(STATSD_PROXY_IMAGE_NAME) $(STATSD_PROXY_DOCKER_DIR) && $(SUDO) docker push $(STATSD_PROXY_IMAGE_NAME))

#-------------------------------------------------------------------------------------------------------------------------------------------------
STATSD_DAEMON_APP_NAME=statsd-daemon
STATSD_DAEMON_DIR_NAME=statsd-daemon
STATSD_DAEMON_DOCKER_DIR=docker/$(STATSD_DAEMON_DIR_NAME)
STATSD_DAEMON_IMAGE_TAG=$(shell git log -n 1 --pretty=format:%h $(STATSD_DAEMON_DOCKER_DIR))
STATSD_DAEMON_IMAGE_NAME=$(DOCKER_REPOSITORY)/$(STATSD_DAEMON_APP_NAME):$(STATSD_DAEMON_IMAGE_TAG)
STATSD_DAEMON_REPLICAS?=$(shell curl -s config/$(NANIT_ENV)/$(STATSD_DAEMON_APP_NAME)/replicas)

define generate-statsd-daemon-svc
	sed -e 's/{{APP_NAME}}/$(STATSD_DAEMON_APP_NAME)/g' kube/$(STATSD_DAEMON_DIR_NAME)/svc.yml
endef

define generate-statsd-daemon-dep
	if [ -z "$(STATSD_DAEMON_REPLICAS)" ]; then echo "ERROR: STATSD_DAEMON_REPLICAS is empty!"; exit 1; fi
	sed -e 's/{{APP_NAME}}/$(STATSD_DAEMON_APP_NAME)/g;s,{{IMAGE_NAME}},$(STATSD_DAEMON_IMAGE_NAME),g;s/{{REPLICAS}}/$(STATSD_DAEMON_REPLICAS)/g' kube/$(STATSD_DAEMON_DIR_NAME)/stateful.set.yml
endef

undeploy-statsd-daemon:
	$(call generate-statsd-daemon-dep) | kubectl delete -f - && $(call generate-statsd-daemon-svc) | kubectl delete -f -

deploy-statsd-daemon: docker-statsd-daemon
	kubectl get svc $(STATSD_DAEMON_APP_NAME) || $(call generate-statsd-daemon-svc) | kubectl create -f -
	$(call generate-statsd-daemon-dep) | kubectl apply -f -

docker-statsd-daemon:
	$(SUDO) docker pull $(STATSD_DAEMON_IMAGE_NAME) || ($(SUDO) docker build -t $(STATSD_DAEMON_IMAGE_NAME) $(STATSD_DAEMON_DOCKER_DIR) && $(SUDO) docker push $(STATSD_DAEMON_IMAGE_NAME))

#-------------------------------------------------------------------------------------------------------------------------------------------------
CARBON_RELAY_APP_NAME=carbon-relay
CARBON_RELAY_DIR_NAME=carbon-relay
CARBON_RELAY_DOCKER_DIR=docker/$(CARBON_RELAY_DIR_NAME)
CARBON_RELAY_IMAGE_TAG=$(shell git log -n 1 --pretty=format:%h $(CARBON_RELAY_DOCKER_DIR))
CARBON_RELAY_IMAGE_NAME=$(DOCKER_REPOSITORY)/$(CARBON_RELAY_APP_NAME):$(CARBON_RELAY_IMAGE_TAG)
CARBON_RELAY_REPLICAS?=$(shell curl -s config/$(NANIT_ENV)/$(CARBON_RELAY_APP_NAME)/replicas)

define generate-carbon-relay-svc
	sed -e 's/{{APP_NAME}}/$(CARBON_RELAY_APP_NAME)/g' kube/$(CARBON_RELAY_DIR_NAME)/svc.yml
endef

define generate-carbon-relay-dep
	if [ -z "$(CARBON_RELAY_REPLICAS)" ]; then echo "ERROR: CARBON_RELAY_REPLICAS is empty!"; exit 1; fi
	sed -e 's/{{APP_NAME}}/$(CARBON_RELAY_APP_NAME)/g;s,{{IMAGE_NAME}},$(CARBON_RELAY_IMAGE_NAME),g;s/{{REPLICAS}}/$(CARBON_RELAY_REPLICAS)/g' kube/$(CARBON_RELAY_DIR_NAME)/dep.yml
endef

undeploy-carbon-relay:
	$(call generate-carbon-relay-dep) | kubectl delete -f - && $(call generate-carbon-relay-svc) | kubectl delete -f -

deploy-carbon-relay: docker-carbon-relay
	kubectl get svc $(CARBON_RELAY_APP_NAME) || $(call generate-carbon-relay-svc) | kubectl create -f -
	$(call generate-carbon-relay-dep) | kubectl apply -f -

docker-carbon-relay:
	$(SUDO) docker pull $(CARBON_RELAY_IMAGE_NAME) || ($(SUDO) docker build -t $(CARBON_RELAY_IMAGE_NAME) $(CARBON_RELAY_DOCKER_DIR) && $(SUDO) docker push $(CARBON_RELAY_IMAGE_NAME))

#-------------------------------------------------------------------------------------------------------------------------------------------------
GRAPHITE_NODE_APP_NAME=graphite-node
GRAPHITE_NODE_DIR_NAME=graphite-node
GRAPHITE_NODE_DOCKER_DIR=docker/$(GRAPHITE_NODE_DIR_NAME)
GRAPHITE_NODE_IMAGE_TAG=$(shell git log -n 1 --pretty=format:%h $(GRAPHITE_NODE_DOCKER_DIR))
GRAPHITE_NODE_IMAGE_NAME=$(DOCKER_REPOSITORY)/$(GRAPHITE_NODE_APP_NAME):$(GRAPHITE_NODE_IMAGE_TAG)
GRAPHITE_NODE_REPLICAS?=$(shell curl -s config/$(NANIT_ENV)/$(GRAPHITE_NODE_APP_NAME)/replicas)
GRAPHITE_NODE_CURATOR_RETENTION?=$(shell curl -s config/$(NANIT_ENV)/$(GRAPHITE_NODE_APP_NAME)/curator_retention)

define generate-graphite-node-svc
	sed -e 's/{{APP_NAME}}/$(GRAPHITE_NODE_APP_NAME)/g' kube/$(GRAPHITE_NODE_DIR_NAME)/svc.yml
endef

define generate-graphite-node-dep
	if [ -z "$(GRAPHITE_NODE_REPLICAS)" ]; then echo "ERROR: GRAPHITE_NODE_REPLICAS is empty!"; exit 1; fi
	sed -e 's/{{APP_NAME}}/$(GRAPHITE_NODE_APP_NAME)/g;s,{{IMAGE_NAME}},$(GRAPHITE_NODE_IMAGE_NAME),g;s/{{REPLICAS}}/$(GRAPHITE_NODE_REPLICAS)/g;s/{{CURATOR_RETENTION}}/$(GRAPHITE_NODE_CURATOR_RETENTION)/g' kube/$(GRAPHITE_NODE_DIR_NAME)/stateful.set.yml
endef

undeploy-graphite-node:
	$(call generate-graphite-node-dep) | kubectl delete -f - && $(call generate-graphite-node-svc) | kubectl delete -f -

deploy-graphite-node: docker-graphite-node
	kubectl get svc $(GRAPHITE_NODE_APP_NAME) || $(call generate-graphite-node-svc) | kubectl create -f -
	$(call generate-graphite-node-dep) | kubectl apply -f -

docker-graphite-node:
	$(SUDO) docker pull $(GRAPHITE_NODE_IMAGE_NAME) || ($(SUDO) docker build -t $(GRAPHITE_NODE_IMAGE_NAME) $(GRAPHITE_NODE_DOCKER_DIR) && $(SUDO) docker push $(GRAPHITE_NODE_IMAGE_NAME))

#-------------------------------------------------------------------------------------------------------------------------------------------------
GRAPHITE_MASTER_APP_NAME=graphite
GRAPHITE_MASTER_DIR_NAME=graphite-master
GRAPHITE_MASTER_DOCKER_DIR=docker/$(GRAPHITE_MASTER_DIR_NAME)
GRAPHITE_MASTER_IMAGE_TAG=$(shell git log -n 1 --pretty=format:%h $(GRAPHITE_MASTER_DOCKER_DIR))
GRAPHITE_MASTER_IMAGE_NAME=$(DOCKER_REPOSITORY)/$(GRAPHITE_MASTER_APP_NAME):$(GRAPHITE_MASTER_IMAGE_TAG)
GRAPHITE_MASTER_REPLICAS?=$(shell curl -s config/$(NANIT_ENV)/$(GRAPHITE_MASTER_APP_NAME)/replicas)

define generate-graphite-master-svc
	sed -e 's/{{APP_NAME}}/$(GRAPHITE_MASTER_APP_NAME)/g' kube/$(GRAPHITE_MASTER_DIR_NAME)/svc.yml
endef

define generate-graphite-master-dep
	if [ -z "$(GRAPHITE_MASTER_REPLICAS)" ]; then echo "ERROR: GRAPHITE_MASTER_REPLICAS is empty!"; exit 1; fi
	sed -e 's/{{APP_NAME}}/$(GRAPHITE_MASTER_APP_NAME)/g;s,{{IMAGE_NAME}},$(GRAPHITE_MASTER_IMAGE_NAME),g;s/{{REPLICAS}}/$(GRAPHITE_MASTER_REPLICAS)/g' kube/$(GRAPHITE_MASTER_DIR_NAME)/dep.yml
endef

undeploy-graphite-master:
	$(call generate-graphite-master-dep) | kubectl delete -f - && $(call generate-graphite-master-svc) | kubectl delete -f -

deploy-graphite-master: docker-graphite-master
	kubectl get svc $(GRAPHITE_MASTER_APP_NAME) || $(call generate-graphite-master-svc) | kubectl create -f -
	$(call generate-graphite-master-dep) | kubectl apply -f -

docker-graphite-master:
	$(SUDO) docker pull $(GRAPHITE_MASTER_IMAGE_NAME) || ($(SUDO) docker build -t $(GRAPHITE_MASTER_IMAGE_NAME) $(GRAPHITE_MASTER_DOCKER_DIR) && $(SUDO) docker push $(GRAPHITE_MASTER_IMAGE_NAME))


deploy: deploy-statsd-proxy deploy-statsd-daemon deploy-carbon-relay deploy-graphite-node deploy-graphite-master

undeploy: undeploy-graphite-master undeploy-graphite-node undeploy-carbon-relay undeploy-statsd-daemon undeploy-statsd-proxy
