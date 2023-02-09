resource "random_string" "random" {
  length  = 3
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_storage_account" "strgacct" {
  name                     = "${var.resourcegroup}strgacct${random_string.random.result}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags

}

resource "azurerm_monitor_diagnostic_setting" "strgacctdiag" {
  name                       = "strgacctdiag"
  target_resource_id         = azurerm_storage_account.strgacct.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "Transaction"
  }
}