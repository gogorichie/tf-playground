resource "azurerm_resource_group" "rg" {
  name     = "${var.resourcegroup}-${var.NS_Application}"
  location = var.location
  tags     = local.tags

}
