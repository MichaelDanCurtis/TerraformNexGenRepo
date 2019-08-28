variable "location" {
  description = "Location of the network"
  default     = "westus"
}

variable "username" {
  description = "Username for Virtual Machines"
  default     = "testadmin"
}

variable "password" {
  description = "Password for Virtual Machines"
  default     = "l3tm31nn0w"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}