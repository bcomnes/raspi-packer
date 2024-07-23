#!/usr/bin/env bash

set -e
set -x

PACKER_VERSION="$1"

# echo "Downloading packer"
# wget -q "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip";
# unzip "packer_${PACKER_VERSION}_linux_amd64.zip"
# #./packer version
# echo "Finished building packer"

# Src build of packer
#echo "Building packer"
#go build -v -o packer github.com/hashicorp/packer
#./packer version
#echo "Finished building packer"

echo "Building github.com/michalfita/packer-plugin-cross"
# Version tracked in go.mod + tools.go
go build -v -o packer-plugin-cross github.com/michalfita/packer-plugin-cross
packer plugins install -path packer-plugin-cross github.com/michalfita/cross 
echo "Finished building github.com/michalfita/packer-plugin-cross"

