#!/bin/sh

set -e

docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
docker tag leifg/release_ping:${1} leifg/release_ping:latest
docker push leifg/release_ping:${1}
docker push leifg/release_ping:latest
