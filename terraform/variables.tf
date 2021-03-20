variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}
variable "resource_pool" {}
variable "network" {}

variable "os_type" {
  type    = string
  default = "linux"
  validation {
    condition     = contains(["linux", "windows"], var.os_type)
    error_message = "Argument 'os_type' must be either 'linux' or 'windows'."
  }
}

// variable "vm_folder" {}
variable "vm_name" {}
variable "vm_template" {}
variable "vm_password" {
  type      = string
  sensitive = true
}
