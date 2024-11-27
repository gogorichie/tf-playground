provider "azurerm" {
  features {}
}

locals {
  tags = merge({ "NS_Application" = var.NS_Application }, { "NS_Environment" = var.NS_Environment }, { "NS_Location" = var.location })
}
resource "azurerm_resource_group" "rg" {
  name     = "${var.appname}-rg"
  location = var.location
  tags     = local.tags

}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "${var.appname}-LAW"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  depends_on = [
    azurerm_resource_group.rg
  ]
}


resource "azurerm_storage_account" "example" {
  name                     = "${var.appname}storage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_storage_container" "example" {
  name                  = "${var.appname}-container"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_eventhub_namespace" "example" {
  name                = "${var.appname}-namespace"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

resource "azurerm_eventhub" "example" {
  name                = "${var.appname}-eventhub"
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_eventhub_namespace.example.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_iothub_consumer_group" "example" {
  name                   = "pj_test_group"
  iothub_name            = azurerm_iothub.example.name
  eventhub_endpoint_name = "events"
  resource_group_name    = azurerm_resource_group.rg.name
}

resource "azurerm_eventhub_authorization_rule" "example" {
  resource_group_name = azurerm_resource_group.rg.name
  namespace_name      = azurerm_eventhub_namespace.example.name
  eventhub_name       = azurerm_eventhub.example.name
  name                = "acctest"
  send                = true
}

resource "azurerm_iothub" "example" {
  name                = "${var.appname}-IoTHub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = azurerm_storage_account.example.primary_blob_connection_string
    name                       = "export"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    container_name             = azurerm_storage_container.example.name
    encoding                   = "Avro"
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  }

  endpoint {
    type              = "AzureIotHub.EventHub"
    connection_string = azurerm_eventhub_authorization_rule.example.primary_connection_string
    name              = "export2"
  }

  route {
    name           = "route1"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export"]
    enabled        = true
  }

  route {
    name           = "route2"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export2"]
    enabled        = true
  }

  cloud_to_device {
    max_delivery_count = 30
    default_ttl        = "PT1H"
    feedback {
      time_to_live       = "PT1H10M"
      max_delivery_count = 15
      lock_duration      = "PT30S"
    }
  }

}
# resource "azurerm_eventhub_authorization_rule" "example" {
#   resource_group_name = "test20"
#   namespace_name      = azurerm_eventhub_namespace.example.name
#   eventhub_name       = azurerm_eventhub.example.name
#   name                = "acctest"
#   send                = true
# }

resource "azurerm_eventgrid_system_topic" "systopic" {
  name                   = "system-topic"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  source_arm_resource_id = azurerm_iothub.example.id
  topic_type             = "Microsoft.Devices.IoTHubs"
  identity {
    type = "SystemAssigned"
  }
}

# resource "azurerm_eventgrid_system_topic_event_subscription" "eventsystopic" {
#   name                 = "send-to-dev-subscription"
#   system_topic         = azurerm_eventgrid_system_topic.systopic.name
#   resource_group_name  = azurerm_resource_group.rg.name
#   eventhub_endpoint_id = "/subscriptions/77121701-c0c2-4c31-8249-1303516b0692/resourceGroups/test20/providers/Microsoft.EventHub/namespaces/test20/eventhubs/test"
#   included_event_types = ["Microsoft.Devices.DeviceTelemetry"]
#   delivery_identity {
#     type = "SystemAssigned"
#   }
#   depends_on = [
#     azurerm_eventgrid_system_topic.systopic
#   ]
# }

# Create an IoT Hub Access Policy
data "azurerm_iothub_shared_access_policy" "example" {
  name                = "iothubowner"
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = azurerm_iothub.example.name
}

# Create a Device Provisioning Service
resource "azurerm_iothub_dps" "example" {
  name                = "${var.appname}-IoTHub-dps"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "S1"
    capacity = 1
  }

  linked_hub {
    connection_string = data.azurerm_iothub_shared_access_policy.example.primary_connection_string
    location          = azurerm_iothub.example.location
  }
}


resource "azurerm_monitor_diagnostic_setting" "logall-iothub" {
  name                       = "alllogs"
  target_resource_id         = azurerm_iothub.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  log {
    category = "Connections"
    enabled  = true
  }
  log {
    category = "DeviceTelemetry"
    enabled  = true
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "logall-iothub-dps" {
  name                       = "alllogs"
  target_resource_id         = azurerm_iothub_dps.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  log {
    category = "DeviceOperations"
    enabled  = true
  }
  log {
    category = "ServiceOperations"
    enabled  = true
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}


resource "azurerm_stream_analytics_job" "example" {
  name                                     = "${var.appname}-job"
  resource_group_name                      = azurerm_resource_group.rg.name
  location                                 = azurerm_resource_group.rg.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 3

  tags = {
    environment = "Example"
  }

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}

resource "azurerm_monitor_diagnostic_setting" "logall-stream-jobs" {
  name                       = "alllogs"
  target_resource_id         = azurerm_stream_analytics_job.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  log {
    category = "Execution"
    enabled  = true
  }
  log {
    category = "Authoring"
    enabled  = true
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}