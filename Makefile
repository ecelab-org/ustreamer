include .env
export

all: run

build: .build_stamp
.build_stamp:
	sudo apt install v4l2loopback-dkms v4l-utils ffmpeg obs-studio -y
	@touch $@

run: build
	docker run --detach --rm \
		--name $(CL_PROJECT_NAME) \
		--device ${CL_HOST_DEV_PATH}:/dev/video0 \
		-p ${CL_PORT}:8080 \
		pikvm/ustreamer:latest \
		--format=${CL_HOST_DEV_FORMAT} \
		--workers=3 \
		--persistent \
		--drop-same-frames=30
	@echo
	@echo "Initializing..."
	@echo
	@sleep 2
	@docker logs $(CL_PROJECT_NAME)

stop: FORCE
	docker stop $(CL_PROJECT_NAME) || :

log: FORCE
	docker logs $(CL_PROJECT_NAME)

log-follow: FORCE
	docker logs -f $(CL_PROJECT_NAME)

debug: FORCE
	docker exec -it $(CL_PROJECT_NAME) \
		sh

clean: stop

Makefile: ;

FORCE:
