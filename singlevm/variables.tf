variable "resourcegroup" {
  type    = string
  default = "beta-use2-loop-spoke-rg"
}

variable "vnet" {
  type = string
  default = "beta-use2-loop-spoke-vnet"
}

variable "subnet" {
  type = string
  default = "websn01"  
}

variable "location" {
  type    = string
  default = "east us 2"
}
#VM Details

variable "vmname" {
  type    = string
  default = "TST-USE2-TFT"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "vmsku" {
  type    = string
  default = "2019-Datacenter"
}

variable "vmsize" {
  type    = string
  default = "Standard_B2s"
}

variable "adminUsername" {
  type    = string
  default = "dest"
}

variable "adminPassword" {
  type    = string
  default = "q2w3e4r5t6$"
}
