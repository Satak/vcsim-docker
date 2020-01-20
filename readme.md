# vCenter Simulator Docker Container

## Docker

Pull this Docker container and run it in 443 port

- `docker pull satak/vcsim`
- `docker run -d --name vcsim -p 443:443 satak/vcsim`

DockerHub: <https://hub.docker.com/r/satak/vcsim>

## Powershell PowerCLI

There is a nice Powershell module for VMware called **PowerCLI**

```txt
VMware PowerCLI is a command-line and scripting tool built on Windows PowerShell, and provides more than 700 cmdlets for managing and automating vSphere, vCloud, vRealize Operations Manager, vSAN, NSX-T, VMware Cloud on AWS, VMware HCX, VMware Site Recovery Manager, and VMware Horizon environments.
```

Install module, connect to vcsim (it doesn't have any authentication so you can use what ever username and password) and get VMs:

```powershell
# first install the vmware powercli module
Install-Module VMware.PowerCLI

# connect to vcsim, this takes 1-2 minutes, -Force switch to bypass the SSL certificate issue. Username and password can be anything, there is no authentication
Connect-VIServer localhost -User 'u' -Password 'p' -Force

# to test the connection just get VMs from the vcsim
Get-VM

<#
Should get something like this:

Name                 PowerState Num CPUs MemoryGB
----                 ---------- -------- --------
DC0_H0_VM0           PoweredOn  1        0.031
DC0_H0_VM1           PoweredOn  1        0.031
DC0_C0_RP0_VM0       PoweredOn  1        0.031
DC0_C0_RP0_VM1       PoweredOn  1        0.031
#>
```

```powershell

# stop VM
Get-VM -Name DC0_H0_VM0 | Stop-VM

# start VM
Get-VM -Name DC0_H0_VM0 | Start-VM
```

## `govc`

govc is a vSphere CLI built on top of govmomi.

gvc binaries: <https://github.com/vmware/govmomi/releases>

Direct links:

- MacOS: <https://github.com/vmware/govmomi/releases/download/v0.22.1/govc_darwin_amd64.gz>
- Windows: <https://github.com/vmware/govmomi/releases/download/v0.22.1/govc_windows_amd64.exe.zip>

```bash
# install govc
URL_TO_BINARY="https://github.com/vmware/govmomi/releases/download/v0.22.1/govc_darwin_amd64.gz"
curl -L $URL_TO_BINARY | gunzip > /usr/local/bin/govc
chmod +x /usr/local/bin/govc

# set envs for your vcsim
export GOVC_URL=https://user:pass@127.0.0.1:443
export GOVC_INSECURE=1
export GOVC_DATASTORE=datastore/LocalDS_0
export GOVC_RESOURCE_POOL=DC0_H0/Resources
export GOVC_NETWORK="network/VM Network"

# powershell env vars
$env:GOVC_URL = "https://user:pass@127.0.0.1:443"

govc find

# set ip and name
govc vm.power -off DC0_H0_VM1
govc vm.customize -vm DC0_H0_VM1 -name fourtythree -ip 10.0.0.43
govc vm.power -on DC0_H0_VM1
# get name and ip
govc object.collect -s vm/DC0_H0_VM1 guest.ipAddress guest.hostName
# get ip
govc vm.ip DC0_H0_VM1

# guestId: windows9Server64Guest

# create VM
# govc vm.create -m 2048 -c 2 -g windows9Server64Guest -net.adapter vmxnet3 -disk.controller pvscsi test-vm
govc vm.create -on=false -host DC0_H0 -version 6.7 -g otherLinux64Guest -c 2 template-vm
```

## Terraform

- Download Terraform CLI from here: <https://www.terraform.io/downloads.html>
- Direct link to Windows x64 version:
  - <https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_windows_amd64.zip>
- Unzip the terraform.exe to some folder and add it to our PATH or CD to that folder so you can use the exe from that folder
- Create these 3 Terraform files to your working folder:
  - `main.tf`
  - `variables.tf`
  - `terraform.tfvars`
- Run these terraform commands:
  - `terraform init`
  - `terraform plan`
  - `terraform apply`
