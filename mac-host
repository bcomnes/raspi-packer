#!/bin/sh

set -x

MAC=$(cat /sys/class/net/*/address | head -1 | sed -r 's/:/-/g')
EXISTING_HOST=$(cat /etc/hostname)

echo "${EXISTING_HOST}-${MAC}" > /etc/hostname
