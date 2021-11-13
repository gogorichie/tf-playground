
provider "azurerm" {
  features {}
}


locals {
  current_time = formatdate("MMM DD, YYYY hh:mm:ss", timestamp())
  tags         = merge({ "Project" = "Terraformlab" }, { "LastModified" = local.current_time }, { "OkToDelete" = "Yes" })
}