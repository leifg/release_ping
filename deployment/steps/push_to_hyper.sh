#!/bin/sh

NEW_VERSION=$1
BUILD_NUM=$2
STARTING_TIMEOUT=2

NEW_CONTAINER_NAME=releaseping-${BUILD_NUM}
echo "Starting New Container ${NEW_CONTAINER_NAME}"

PREV_RUNNING_CONTAINER_ID=$(hyper ps | grep releaseping | head -n 1 | awk '{print $1}')

echo "Create EventStore"

hyper run --rm \
  --size=s2 \
  -e REPLACE_OS_VARS=true \
  -e PRODUCTION_COOKIE=${PRODUCTION_COOKIE} \
  -e POSTGRES_HOST=${POSTGRES_HOST} \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  leifg/release_ping:${NEW_VERSION} \
  db.create
echo "Run Migrations"

hyper run --rm \
  --size=s2 \
  -e REPLACE_OS_VARS=true \
  -e PRODUCTION_COOKIE=${PRODUCTION_COOKIE} \
  -e POSTGRES_HOST=${POSTGRES_HOST} \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  leifg/release_ping:${NEW_VERSION} \
  migrate

hyper run -d \
  --size=s2 \
  --name ${NEW_CONTAINER_NAME} \
  -e REPLACE_OS_VARS=true \
  -e PRODUCTION_COOKIE=${PRODUCTION_COOKIE} \
  -e POSTGRES_HOST=${POSTGRES_HOST} \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  leifg/release_ping:${NEW_VERSION}

echo "Waiting for container to be running"

sleep ${STARTING_TIMEOUT}
NEW_RUNNING_CONTAINER_ID=$(hyper ps --format "{{.ID}}" -f "name=${NEW_CONTAINER_NAME}")

if [[ -z ${NEW_RUNNING_CONTAINER_ID} ]]; then
  echo "Container could not start"
  echo ""
  echo "Logs:"
  hyper logs --tail=all ${NEW_CONTAINER_NAME}
  echo ""
  echo "Cleaning Up"
  hyper rm ${NEW_CONTAINER_NAME}
  exit 2
fi

if [[ ! -z ${PREV_RUNNING_CONTAINER_ID} ]]; then
  container_name=$(hyper ps -a --format "{{.Names}}" -f "id=${PREV_RUNNING_CONTAINER_ID}")
  echo "Shutting Down ${container_name}"
  hyper stop ${PREV_RUNNING_CONTAINER_ID}
  hyper rm ${PREV_RUNNING_CONTAINER_ID}
fi
