#!/usr/bin/env bash

set -e
set -x
# We have to install new bsdtar since the ubuntu version is old

VERSION="$1"

if [[ ! -d "./libarchive-${VERSION}" || ! -f "./libarchive-${VERSION}/Makefile" ]]; then
  wget -q "https://www.libarchive.org/downloads/libarchive-${VERSION}.tar.gz";
  tar xzf "libarchive-${VERSION}.tar.gz"
  cd "libarchive-${VERSION}"
  ./configure
  make
else
  cd "libarchive-${VERSION}"
fi
make install
bsdtar --version
