### Create Spring Cloud Service
resource "azurerm_spring_cloud_service" "sc" {
  name                = "${azurerm_resource_group.rg.name}-springcloud"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "S0"
  zone_redundant      = false

  config_server_git_setting {
    uri = "https://github.com/Azure-Samples/spring-petclinic-microservices-config"
  }

  trace {
    connection_string = azurerm_application_insights.apm.connection_string
    sample_rate       = 10.0
  }

  depends_on = [azurerm_resource_group.rg]
  tags       = local.tags

}

resource "azurerm_spring_cloud_app" "scapp" {
  name                = "${azurerm_resource_group.rg.name}-springcloudapp"
  resource_group_name = azurerm_resource_group.rg.name
  service_name        = azurerm_spring_cloud_service.sc.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_spring_cloud_java_deployment" "scjdp" {
  name                = "api-gateway"
  spring_cloud_app_id = azurerm_spring_cloud_app.scapp.id
  instance_count      = 1
  jvm_options         = "-XX:+PrintGC"
  runtime_version     = "Java_11"

  quota {
    cpu    = "1"
    memory = "2Gi"
  }
}

resource "azurerm_spring_cloud_java_deployment" "scjdp2" {
  name                = "customers-service"
  spring_cloud_app_id = azurerm_spring_cloud_app.scapp.id
  instance_count      = 1
  jvm_options         = "-XX:+PrintGC"
  runtime_version     = "Java_11"

  quota {
    cpu    = "1"
    memory = "2Gi"
  }

  environment_variables = {
    "Env" : "Staging"
  }
}

resource "azurerm_spring_cloud_active_deployment" "scad" {
  spring_cloud_app_id = azurerm_spring_cloud_app.scapp.id
  deployment_name     = azurerm_spring_cloud_java_deployment.scjdp.name
}

### Update Diags setting for Spring Cloud Service

resource "azurerm_monitor_diagnostic_setting" "sc_diag" {
  name                       = "monitoring"
  target_resource_id         = azurerm_spring_cloud_service.sc.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "ApplicationConsole"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
