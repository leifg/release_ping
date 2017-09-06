#!/bin/sh

set -e

MIX_ENV=prod mix release --env=prod
