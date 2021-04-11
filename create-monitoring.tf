resource "azurerm_log_analytics_workspace" "law" {
  name                = "${azurerm_resource_group.rg.name}-LOG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Free"
}

resource "azurerm_application_insights" "apm" {
  name                = "${azurerm_resource_group.rg.name}-APPINSIGHTS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}