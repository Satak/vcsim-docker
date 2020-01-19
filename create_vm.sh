export GOVC_URL=https://user:pass@127.0.0.1:443
export GOVC_INSECURE=1
export GOVC_DATASTORE=datastore/LocalDS_0
export GOVC_RESOURCE_POOL=DC0_C0/Resources
export GOVC_NETWORK="network/VM Network"

VM_NAME=template-vm
GUEST_OS1=windows8Server64Guest
GUEST_OS2=windows9Server64Guest

govc vm.create -m 2048 -c 2 -g $GUEST_OS2 -net.adapter vmxnet3 -disk.controller pvscsi $VM_NAME
