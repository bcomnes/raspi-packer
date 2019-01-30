echo "Building packer"
go get -v -u github.com/hashicorp/packer
go build -v -o packer github.com/hashicorp/packer
./packer version
echo "Finished building packer"

echo "Building solo-io/packer-builder-arm-image"
go get -v -u github.com/solo-io/packer-builder-arm-image
go build -v -o packer-builder-arm-image github.com/solo-io/packer-builder-arm-image
echo "Finished building solo-io/packer-builder-arm-image"
