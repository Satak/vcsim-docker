provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  is_windows = var.os_type == "windows" ? [1] : []
  is_linux   = var.os_type == "linux" ? [1] : []
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  num_cpus = 2
  memory   = 1024

  // folder = var.vm_folder

  disk {
    label = "disk0"
    size  = 20 # data.vsphere_virtual_machine.template.disks.0.size
  }

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }


  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {

      dynamic "linux_options" {
        for_each = local.is_linux
        content {
          host_name = var.vm_name
          domain    = "test.internal"
        }
      }

      dynamic "windows_options" {
        for_each = local.is_windows
        content {
          computer_name  = var.vm_name
          workgroup      = "WORKGROUP"
          admin_password = var.vm_password
        }
      }

      network_interface {
        ipv4_address = "10.134.3.162"
        ipv4_netmask = "24"
      }
    }

  }

  wait_for_guest_net_routable = false
  wait_for_guest_ip_timeout   = 0
  wait_for_guest_net_timeout  = -1
}
