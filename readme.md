# vCenter Simulator Docker Container

![docker pulls](https://img.shields.io/docker/pulls/satak/vcsim.svg)
![docker size](https://img.shields.io/docker/image-size/satak/vcsim.svg)
![docker version](https://img.shields.io/docker/v/satak/vcsim.svg)

| Last Build Time |
| --------------- |
| 18.11.2020      |

<img src="https://img.icons8.com/color/96/000000/vmware.png">

`vcsim` is a nice vCenter simulator by VMware. It's made with golang and needs to be compiled before use. Easiest way to run it, is to run it in a Docker container. This repository has the ready-to-use container source that you can pull from the Docker Hub as a working Docker Image and run it.

After vcsim container running in your Docker environment you can interact with it with different CLI tools like Powershell or govc. You can even use Terraform against vcsim but currently it's a bit limited since you can't really clone VMs with it.

When you start vcsim it has it's own default configuration with datastores, vms, resource pools and vms that are documented at the end of this document in the Terraform section. You can also put existing VMware configuration from your real vCenter environment and put it in the simulator that is documented here: <https://github.com/vmware/govmomi/wiki/vcsim-features>

vcsim repository: <https://github.com/vmware/govmomi/tree/master/vcsim>

## Docker

Pull this Docker container and run it in local `443` port

- `docker pull satak/vcsim`
- `docker run -d --name vcsim -p 443:443 satak/vcsim`

DockerHub url: <https://hub.docker.com/r/satak/vcsim>

---

## CLI tools

## Powershell PowerCLI

<img src="https://img.icons8.com/color/96/000000/powershell.png">

You can interact with vcsim with different cmdline tools like **PowerCLI**, which is a nice Powershell module for VMware.

```txt
VMware PowerCLI is a command-line and scripting tool built on Windows PowerShell, and provides more than 700 cmdlets for managing and automating vSphere, vCloud, vRealize Operations Manager, vSAN, NSX-T, VMware Cloud on AWS, VMware HCX, VMware Site Recovery Manager, and VMware Horizon environments.
```

Install **PowerCLI** module, connect to vcsim (it doesn't have any authentication so you can use what ever username and password) and get VMs:

```powershell
# first install the vmware powercli module
Install-Module VMware.PowerCLI -AllowClobber

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

# stop VM
Get-VM -Name DC0_H0_VM0 | Stop-VM

# start VM
Get-VM -Name DC0_H0_VM0 | Start-VM
```

## `govc`

govc is a vSphere CLI built on top of govmomi.

govc binaries: <https://github.com/vmware/govmomi/releases>

Direct links:

- MacOS: <https://github.com/vmware/govmomi/releases/download/v0.22.1/govc_darwin_amd64.gz>
- Windows: <https://github.com/vmware/govmomi/releases/download/v0.22.1/govc_windows_amd64.exe.zip>

### Windows Installation

<img src="https://img.icons8.com/color/48/000000/windows-10.png">

For Windows just download the govc, rename the downloaded binary to `govc.exe` and move it to `C:\Program Files\govc`, add that path to environment variables so you can then use `govc` from any location.

### Linux / MacOS

<img src="https://img.icons8.com/color/48/000000/linux.png">

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

<img alt="Terraform" src="https://cdn.rawgit.com/hashicorp/terraform-website/master/content/source/assets/images/logo-hashicorp.svg" width="300px">

Terraform is the leading infrastructure as code (IaC) platform that supports wide variety of APIs like VMware vCenter. We can use Terraform against vcsim too, but currently the support is a bit limited because assets in vcsim are not fully configured for Terraform usage.

- Terraform homepage: <https://www.terraform.io/>
- Terraform vSphere provider: <https://www.terraform.io/docs/providers/vsphere/index.html>

### Installation

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

### Working variables for vcsim

```terraform
vsphere_user     = "username"
vsphere_password = "password"
vsphere_server   = "localhost"

datacenter    = "DC0"
cluster       = "DC0_H0"
datastore     = "datastore/LocalDS_0"
resource_pool = "DC0_H0/Resources"
network       = "network/VM Network"

vm_name     = "vcsimtest"
vm_template = "test-vm"
vm_folder   = "vm"
vm_password = "password"
```
