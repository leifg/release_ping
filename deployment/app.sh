#!/bin/sh

export IP_ADDR=`awk 'END{print $1}' /etc/hosts`
/app/bin/release_ping migrate
/app/bin/release_ping "$@"
