#!/usr/bin/env bash

set -e
set -x

PACKER_VERSION="$1"
ARM_BUILDER_VERSION="$2"

echo "Downloading packer"
wget -q "https://releases.hashicorp.com/packer/1.5.5/packer_${PACKER_VERSION}_linux_amd64.zip";
unzip "packer_${PACKER_VERSION}_linux_amd64.zip"
./packer version
echo "Finished building packer"

echo "downloading solo-io/packer-builder-arm-image"
wget -q "https://github.com/solo-io/packer-builder-arm-image/releases/download/v${ARM_BUILDER_VERSION}/packer-builder-arm-image"
wget -q "https://github.com/solo-io/packer-builder-arm-image/releases/download/v${ARM_BUILDER_VERSION}/flasher"
chmod +x ./packer-builder-arm-image
chmod +x ./flasher
echo "Finished building solo-io/packer-builder-arm-image"

ls -la
