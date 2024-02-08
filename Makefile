include .env
export

all: run

build: .build_stamp
.build_stamp:
	sudo apt install v4l2loopback-dkms v4l-utils ffmpeg obs-studio -y
	@touch $@

# Set --buffers=1, until these are resolved:
#   https://github.com/pikvm/ustreamer/issues/43
#   https://github.com/umlaeute/v4l2loopback/issues/304
# When resolved set to 2 or 3
# See help for all options here: https://manpages.debian.org/unstable/ustreamer/ustreamer.1.en.html
run: build stop
	docker run --detach --rm \
		--name $(CL_PROJECT_NAME) \
		--device ${CL_HOST_DEV_PATH}:/dev/video0 \
		-p ${CL_PORT}:8080 \
		pikvm/ustreamer:latest \
		--format=${CL_HOST_DEV_FORMAT} \
		--workers=3 \
		--buffers=1 \
		--persistent \
		--resolution=1280x1440 \
		--desired-fps=20 \
		--encoder=HW \
		--slowdown \
		--log-level 1 \
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
