#!/usr/bin/env bash

set -e
set -x

PACKER_VERSION="$1"

echo "Downloading packer"
wget -q "https://releases.hashicorp.com/packer/1.5.5/packer_${PACKER_VERSION}_linux_amd64.zip";
unzip "packer_${PACKER_VERSION}_linux_amd64.zip"
./packer version
echo "Finished building packer"

echo "Building solo-io/packer-builder-arm-image"
go get -v -u github.com/solo-io/packer-builder-arm-image
go build -v -o packer-builder-arm-image github.com/solo-io/packer-builder-arm-image
echo "Finished building solo-io/packer-builder-arm-image"
