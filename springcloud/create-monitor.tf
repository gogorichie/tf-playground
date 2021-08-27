resource "azurerm_application_insights" "sc_app_insights" {
  name                = "${azurerm_resource_group.rg.name}-APPINSIGHTS"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  depends_on = [azurerm_resource_group.rg]
}

# resource "azurerm_monitor_diagnostic_setting" "sc_diag" {
#   name                        = "monitoring"
#   target_resource_id          = azurerm_spring_cloud_service.sc.id
#   log_analytics_workspace_id = "/subscriptions/${var.subscription}/resourceGroups/${var.azurespringcloudvnetrg}/providers/Microsoft.OperationalInsights/workspaces/${var.sc_law_id}"

#   log {
#     category = "ApplicationConsole"
#     enabled  = true

#     retention_policy {
#       enabled = false
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = false
#     }
#   }
# }