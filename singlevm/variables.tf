variable "location" {
  type    = string
  default = "east us 2"
}

variable "snname" {
  type    = string
  description = "Existing Subnet Name"
}

variable "vnetname" {
  type    = string
    description = "Existing vNet Name"
}

variable "rg" {
  type    = string
    description = "Existing Resource Group Name"
}
#VM Details

variable "vmname" {
  type    = string
  default = "TST-USE2-TFT"
}

variable "vmsku" {
  type    = string
  default = "2019-Datacenter"
}

variable "vmsize" {
  type    = string
  default = "Standard_B4ms"
}

variable "adminUsername" {
  type    = string
  default = "tstadmin"
}

variable "adminPassword" {
  type    = string
  default = "ThisIsABadPassw0rd!"
}

