resource "azurerm_monitor_diagnostic_setting" "vnetlogdemo" {
  name                       = "diag2law"
  target_resource_id         = azurerm_virtual_network.logdemo.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logdemo.id

  metric {
    category = "AllMetrics"
  }
  log {
    category = "VMProtectionAlerts"
  }
}

resource "azurerm_monitor_diagnostic_setting" "niclogdemo" {
  name                       = "diag2law"
  target_resource_id         = azurerm_network_interface.logdemo.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logdemo.id

  metric {
    category = "AllMetrics"
  }
}