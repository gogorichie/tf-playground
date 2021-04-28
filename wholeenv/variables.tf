variable "resourcegroup" {
  type    = string
  default = "tst04272021"
}

variable "location" {
  type    = string
  default = "east us"
}
#VM Details

variable "vmname" {
  type    = string
  default = "TSTEUSWIN"
}

variable "linuxvmname" {
  type    = string
  default = "TSTEUSLIN"
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
  default = "Standard_B1s"
}

variable "adminUsername" {
  type    = string
  default = "AdminRich"
}

variable "adminPassword" {
  type    = string
  default = "RUeBeprk9g5v"
}
