variable "resourcegroup" {
  type    = string
  default = "rlewis"
}

variable "NS_Environment" {
  type    = string
  default = "test"
}

variable "NS_Application" {
  type    = string
  default = "lab"
}

variable "location" {
  type    = string
  default = "east us 2"
}
#VM Details

variable "winvmname" {
  type    = string
  default = "TSTEUSWIN"
}

variable "linuxvmname" {
  type    = string
  default = "TSTEUSLIN"
}

variable "node_count" {
  type    = number
  default = 4
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
