#!/usr/bin/env bash

# Run in a chroot context

set -e
set -x

if [[ -f ./whatever.foo ]]; then
  echo 'file exists'
else
  echo 'does not existt'
fi
