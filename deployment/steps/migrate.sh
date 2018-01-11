#!/bin/sh

set -e

service_name=release-ping-migrator-${2}

echo "Running ${service_name}"
docker-cloud service run --sync \
  -e REPLACE_OS_VARS=true \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  -e POSTGRES_HOST=${POSTGRES_HOST} \
  -e POSTGRES_PORT=${POSTGRES_PORT} \
  -e EVENTSTORE_DB=${EVENTSTORE_DB} \
  -e READSTORE_DB=${READSTORE_DB} \
  -e NODE_COOKIE=${NODE_COOKIE} \
  -e TIMBER_LOGS_KEY=${TIMBER_LOGS_KEY} \
  -n ${service_name} \
  --link-service ${POSTGRES_HOST}.production:${POSTGRES_HOST} \
  --autodestroy ON_SUCCESS \
  --run-command migrate \
  leifg/release_ping:${1}
