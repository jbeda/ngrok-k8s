ifeq ($(VERBOSE), 1)
	DOCKER_BUILD_FLAGS :=
	CURL_FLAGS :=
	VERBOSE_OUTPUT := >&1
else
	CURL_FLAGS := -s
	DOCKER_BUILD_FLAGS := -q
	VERBOSE_OUTPUT := >/dev/null
	MAKEFLAGS += -s
endif

VERSION ?= $(shell git describe --tags --always --dirty)
REGISTRY ?= gcr.io/kuar-demo
IMAGE_NAME := $(REGISTRY)/ngrok
BUILDSTAMP_NAME := $(subst /,_,$(IMAGE_NAME))
IMAGE_BUILDSTAMP := .$(BUILDSTAMP_NAME)-container
PUSH_BUILDSTAMP := .$(BUILDSTAMP_NAME)-push
VERSION ?= $(shell git describe --tags --always --dirty)

NGROK_URL := https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip

.PHONY: build
build: $(IMAGE_BUILDSTAMP)

$(IMAGE_BUILDSTAMP): out/ngrok Dockerfile
	docker build \
		$(DOCKER_BUILD_FLAGS) \
		-t $(IMAGE_NAME):$(VERSION) .
	echo "$(IMAGE_NAME):$(VERSION)" > $@

out/ngrok:
	mkdir -p $(@D) && \
	cd $(@D) && \
	curl $(CURL_FLAGS) -L -o ngrok.zip $(NGROK_URL) && \
	unzip ngrok.zip

.PHONY: push
push: $(PUSH_BUILDSTAMP)

$(PUSH_BUILDSTAMP): $(IMAGE_BUILDSTAMP)
	@echo "pushing  :" $$(sed -n '1p' $<)
	gcloud docker -- push $$(sed -n '1p' $<)
	cat $< > $@

.PHONY: clean
clean:
	rm -f .*-container .*-push
	rm -rf out
