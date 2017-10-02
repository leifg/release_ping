#!/bin/sh

set -e

NEW_VERSION=$1

hyper -R ${HYPER_REGION} login -u ${DOCKER_USER} -e ${DOCKER_EMAIL} -p ${DOCKER_PASS}

echo "Run Migrations"

hyper -R ${HYPER_REGION} run --rm \
  --size=s4 \
  -e REPLACE_OS_VARS=true \
  -e TIMBER_LOGS_KEY=${TIMBER_LOGS_KEY} \
  -e SECRET_KEY_BASE=${SECRET_KEY_BASE} \
  -e NODE_COOKIE=${NODE_COOKIE} \
  -e POSTGRES_HOST=${POSTGRES_HOST} \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  leifg/release_ping:${NEW_VERSION} \
  migrate

echo "Replace running container"

hyper -R ${HYPER_REGION} service rolling-update --image leifg/release_ping:${NEW_VERSION} release-ping-service