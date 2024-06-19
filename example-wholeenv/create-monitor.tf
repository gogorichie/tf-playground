resource "azurerm_monitor_action_group" "actiongroup" {
  name                = "${var.NS_Application}-CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "p0action"

  webhook_receiver {
    name                    = "Azure Logic App"
    service_uri             = "https://prod-32.westus.logic.azure.com:443/workflows/7873b2bce59f49b892e43e6c9d257a9c/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=CvthMaEU6ca9vRKF8E_llGPzK1pJIdfu1Q5lfYLyBuM"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "strgacctalert" {
  name                = "${var.NS_Application}-metricalert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_storage_account.strgacct.id]
  description         = "Action will be triggered when Transactions count is greater than 50."

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50

    dimension {
      name     = "ApiName"
      operator = "Include"
      values   = ["*"]
    }
  }
}