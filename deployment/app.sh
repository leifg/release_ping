#!/bin/sh

export IP_ADDR=`hostname -i`
/app/bin/release_ping "$@"
