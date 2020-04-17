#!/usr/bin/env bash

set -e
set -x
# We have to install new bsdtar since the ubuntu version is old

VERSION="$1"

if [[ ! -d "./qemu-${VERSION}" || ! -f "./qemu-${VERSION}/Makefile" ]]; then
  wget -q "https://download.qemu.org/qemu-${VERSION}.tar.xz";
  tar xvJf "qemu-${VERSION}.tar.xz"
  cd "qemu-${VERSION}"
  ./configure
  make
else
  cd "qemu-${VERSION}"
fi
make install
ls -la /usr/bin/ | grep qemu
