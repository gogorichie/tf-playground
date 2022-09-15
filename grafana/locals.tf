locals {
  rg = {
    name     = "rg-az-managed-grafana-sample"
    location = "southcentralus"
  }
}

data "azurerm_client_config" "current" {}