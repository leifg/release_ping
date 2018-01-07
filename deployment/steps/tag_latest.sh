#!/bin/sh

set -e

docker tag leifg/release_ping:${1} leifg/release_ping:latest
docker push leifg/release_ping:latest
