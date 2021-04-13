variable "resourcegroup" {
  type    = string
  default = "tstrg04112021"
}

variable "location" {
  type    = string
  default = "east us"
}
#VM Details

variable "vmname" {
  type    = string
  default = "TST-EUS-TFT"
}

variable "node_count" {   
     type = number
    default = 5     
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
