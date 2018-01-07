#!/bin/sh

set -e

docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
docker push leifg/release_ping:${1}
