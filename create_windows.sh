#!/bin/bash -e

export GOVC_URL=https://user:pass@127.0.0.1:443
export GOVC_INSECURE=1
export GOVC_DATASTORE=datastore1
export GOVC_NETWORK="VM Network"

dir=winsrv2012r2
disk="${dir}.vmdk"

if [ "$(uname -s)" = "Darwin" ]; then
  PATH="/Applications/VMware Fusion.app/Contents/Library:$PATH"
fi

if ! govc datastore.ls "${dir}/${disk}" 1>/dev/null 2>&1
then
  if [ ! -e $disk ]
  then
    echo "converting vagrant box to single vmdk..."
    vmware-vdiskmanager \
      -r ~/.vagrant.d/boxes/vmware-VAGRANTSLASH-windows_2012_r2/0/vmware_desktop/disk.vmdk \
      -t 0 $disk
  fi

  echo "importing vmdk to datastore ${GOVC_DATASTORE}..."
  govc import.vmdk $disk $dir
fi

vm_name="${USER}-windows-box" # TODO: should be configurable

if [ "$1" = "--recreate" ]
then
    if [ -n "$(govc ls "vm/$vm_name")" ]
  then
    echo "destroying VM..."
    govc vm.destroy "$vm_name"
  fi
fi

if [ -z "$(govc ls "vm/$vm_name")" ]
then
  echo "creating VM ${vm_name}..."
  # Note: windows goes into repair mode with the default disk.controller (lsilogic)
  # Note: windows network does not work with the default net.adapter (e1000)
  govc vm.create -m 8192 -c 2 -g windows8Server64Guest \
       -disk.controller lsilogic-sas \
       -net.adapter vmxnet3 \
       -on=false "$vm_name"

  govc vm.disk.attach -vm "$vm_name" -link=true -disk $dir/$disk

  govc vm.power -on "$vm_name"
fi

# An ipv6 is reported by tools when the machine is first booted.
# Wait until we get an ipv4 address from tools.
while true
do
  ip=$(govc vm.ip "$vm_name")
  ipv4="${ip//[^.]}"
  if [ "${#ipv4}" -eq 3 ]
  then
    break
  fi
  sleep 1
done

echo "VM ip=$ip"

# don't bother creating a jenkins user, just use the existing vagrant user
export GOVC_GUEST_LOGIN=vagrant:vagrant

folder=c:\\Users\\vagrant

private_key=../../saltbase/salt/jenkins/ssh/id_rsa

echo "uploading ssh private key..."
govc guest.upload -f -vm "$vm_name" $private_key $folder\\.ssh\\id_rsa
echo "uploading ssh authorized_keys..."
govc guest.upload -f -vm "$vm_name" ../../saltbase/salt/jenkins/ssh/authorized_keys $folder\\.ssh\\authorized_keys
echo "uploading provisioning script..."
govc guest.upload -f -vm "$vm_name" "$(dirname "$0")/provision.ps1" $folder\\provision.ps1

echo "provisioning..."

eval "$(ssh-agent)"
trap 'kill $SSH_AGENT_PID' EXIT
chmod 600 $private_key
ssh-add $private_key

ssh "vagrant@$ip" powershell -file provision.ps1

# reboot to make sure machine wide registry environment settings are applied
echo "Rebooting VM..."
govc vm.power -r "$vm_name"