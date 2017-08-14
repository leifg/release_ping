#!/bin/sh
docker login -u ${2} -p ${3}
docker tag leifg/release_ping:${1} leifg/release_ping:latest
docker push leifg/release_ping:${1}
docker push leifg/release_ping:latest
