resource "azurerm_log_analytics_workspace" "law" {
  name                = "${azurerm_resource_group.rg.name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags

}

resource "azurerm_application_insights" "apm" {
  name                = "${azurerm_resource_group.rg.name}-APPINSIGHTS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  depends_on          = [azurerm_resource_group.rg]

}

