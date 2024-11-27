variable "location" {
  type = string
}

variable "snname" {
  type        = string
  description = "Existing Subnet Name"
}

variable "vnetname" {
  type        = string
  description = "Existing vNet Name"
}

variable "rg" {
  type        = string
  description = "Existing Resource Group Name"
}
#VM Details

variable "vmname" {
  type = string
}

variable "vmsku" {
  type = string
}

variable "vmsize" {
  type = string
}

variable "adminUsername" {
  type = string
}

variable "adminPassword" {
  type      = string
  sensitive = true
}

