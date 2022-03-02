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

resource "azurerm_virtual_machine_extension" "mmaagent" {
  name                 = "mmaagent"
  virtual_machine_id   = azurerm_virtual_machine.logdemo.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = "true"
  settings = <<SETTINGS
    {
      "workspaceId": azurerm_network_interface.logdemo.workspace_id
    }
SETTINGS
   protected_settings = <<PROTECTED_SETTINGS
   {
      "workspaceKey": azurerm_log_analytics_workspace.logdemo.primary_shared_key
   }
PROTECTED_SETTINGS
}