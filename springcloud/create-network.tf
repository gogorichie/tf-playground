resource "azurerm_virtual_network" "vnet" {
  name                = "${azurerm_resource_group.rg.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

}

resource "azurerm_monitor_diagnostic_setting" "vnetdiag" {
  name                       = "diag2law"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
  }
  log {
    category = "VMProtectionAlerts"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${azurerm_resource_group.rg.name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

}

resource "azurerm_network_security_rule" "nsr" {
  name                        = "test123"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_monitor_diagnostic_setting" "nsg-diagnostics" {
  name                       = "diag2law"
  target_resource_id         = azurerm_network_security_group.nsg.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  log {
    category = "NetworkSecurityGroupEvent"
    enabled  = true
  }
  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true
  }
}