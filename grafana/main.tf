terraform {
#   required_version = "~> 1.1.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.2.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 0.1.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.21.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}

resource "azurerm_resource_group" "grafana_sample" {
  name     = local.rg.name
  location = local.rg.location
}

resource "azurerm_storage_account" "sample_target" {
  name                     = "${var.prefix}azgrfsample"
  resource_group_name      = azurerm_resource_group.grafana_sample.name
  location                 = azurerm_resource_group.grafana_sample.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// TODO: This will be replaced with AzureRM provider once it is available
resource "azapi_resource" "grafana" {
  type      = "Microsoft.Dashboard/grafana@2021-09-01-preview"
  name      = "grafana-sample"
  parent_id = azurerm_resource_group.grafana_sample.id

  body = jsonencode({
    location   = azurerm_resource_group.grafana_sample.location
    properties = {}
    sku = {
      name = "Standard"
    }
    identity = {
      type = "SystemAssigned"
    }
  })

  response_export_values = ["properties.endpoint", "identity.principalId"]
}

// The document says
// "By default, when a Grafana workspace is created, Azure Managed Grafana grants it the Monitoring Reader role for all Azure Monitor data and Log Analytics resources within a subscription."
// but it seems not set so far, so it'll assign it.
// https://docs.microsoft.com/en-us/azure/managed-grafana/how-to-permissions
resource "azurerm_role_assignment" "grafana_rg" {
  scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  // Monitoring Reader
  // https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#monitoring-reader
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/43d0d8ad-25c7-4714-9337-8ba259a9fe05"
  principal_id       = jsondecode(azapi_resource.grafana.output).identity.principalId
}

data "external" "grafana_token" {
  program = ["/bin/bash", "-c", "${path.module}/get_grafana_token.sh"]

  query = {
    client_id     = var.service_principal.client_id
    client_secret = var.service_principal.client_secret
    tenant_id     = data.azurerm_client_config.current.tenant_id
  }
}

data "http" "dashboard_azure_monitor_storage_insights" {
  url = "https://grafana.com/api/dashboards/14469/revisions/1/download"

  request_headers = {
    Accept = "application/json"
  }
}

data "template_file" "dashboard_azure_monitor_storage_insights" {
  template = data.http.dashboard_azure_monitor_storage_insights.body
  vars = {
    DS_AZURE_MONITOR = "azure-monitor-oob"
    VAR_NS           = "Microsoft.Storage/storageAccounts"
  }
}

provider "grafana" {
  alias  = "base"
  url    = jsondecode(azapi_resource.grafana.output).properties.endpoint
  auth   = data.external.grafana_token.result["token"]
  org_id = 1
}

resource "grafana_dashboard" "azure_monitor_storage_insights" {
  provider    = grafana.base
  config_json = data.template_file.dashboard_azure_monitor_storage_insights.rendered
}