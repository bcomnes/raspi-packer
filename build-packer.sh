echo "Building packer"
go get github.com/hashicorp/packer
go build -o packer github.com/hashicorp/packer
./packer version
echo "Finished building packer"

echo "Building solo-io/packer-builder-arm-image"
go get github.com/solo-io/packer-builder-arm-image
go build -o packer-builder-arm-image github.com/solo-io/packer-builder-arm-image
echo "Finished building solo-io/packer-builder-arm-image"
