
provider "azurerm" {
  features {}
}


locals {
  current_time = formatdate("MMM DD, YYYY hh:mm:ss", timestamp())
  tags         = merge({ "environment" = var.NS_Environment }, { "Project" = var.Project })
}