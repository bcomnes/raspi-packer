#!/usr/bin/env bash

set -e
set -x

PACKER_VERSION="$1"

echo "Downloading packer"
wget -q "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip";
unzip "packer_${PACKER_VERSION}_linux_amd64.zip"
#./packer version
echo "Finished building packer"

# echo "Building packer"
# go build -v -o packer github.com/hashicorp/packer
# ./packer version
# echo "Finished building packer"

echo "Building github.com/mkaczanowski/packer-builder-arm"
go build -v -o packer-builder-arm github.com/mkaczanowski/packer-builder-arm
echo "Finished building github.com/mkaczanowski/packer-builder-arm"

