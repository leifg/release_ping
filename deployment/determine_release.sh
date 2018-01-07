#!/bin/sh

if [[ -z "${GH_TOKEN}" ]]; then
  echo "GH_TOKEN not set"
  exit 1
fi

VERSION=$(semantic-release -dry -vf -slug leifg/release_ping -noci 2>&1 | grep "new version:" | egrep -o -e '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

if [ -n "${VERSION}" ]; then
  echo "New Version: ${VERSION}"
  echo ${VERSION} > .version
fi
