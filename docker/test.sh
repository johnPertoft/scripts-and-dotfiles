#!/bin/bash

IMAGE="ubuntu-test-install-script"

set -e
docker build -t ${IMAGE} -f docker/Dockerfile .
docker run -it --rm ${IMAGE}
docker rmi ${IMAGE}