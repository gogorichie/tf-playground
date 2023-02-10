
provider "azurerm" {
  features {}
}


locals {
  tags = merge({ "environment" = var.NS_Environment }, { "application" = var.NS_Application })
}