#!/bin/sh

docker build --build-arg VERSION=${1} -t leifg/release_ping:${1} .