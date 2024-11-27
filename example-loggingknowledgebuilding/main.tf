provider "azurerm" {
  features {}
}

locals {
  current_time = formatdate("MMM DD, YYYY hh:mm:ss", timestamp())
  tags         = merge({ "Project" = "Terraformlab" }, { "LastModified" = local.current_time }, { "OkToDelete" = "Yes" })
}

resource "random_password" "vmpassword" {
  length  = 20
  special = true
}

resource "azurerm_resource_group" "logdemo" {
  name     = "logdemo-resources"
  location = "northcentralus"
  tags     = local.tags

}

resource "azurerm_log_analytics_workspace" "logdemo" {
  name                = "logdemo-law"
  location            = azurerm_resource_group.logdemo.location
  resource_group_name = azurerm_resource_group.logdemo.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
  depends_on          = [azurerm_resource_group.logdemo]

}


resource "azurerm_virtual_network" "logdemo" {
  name                = "logdemo-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.logdemo.location
  resource_group_name = azurerm_resource_group.logdemo.name
  tags                = local.tags

}

resource "azurerm_subnet" "logdemo" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.logdemo.name
  virtual_network_name = azurerm_virtual_network.logdemo.name
  address_prefixes     = ["10.0.2.0/24"]

}

resource "azurerm_network_interface" "logdemo" {
  name                = "logdemo-nic"
  location            = azurerm_resource_group.logdemo.location
  resource_group_name = azurerm_resource_group.logdemo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.logdemo.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags

}

resource "azurerm_windows_virtual_machine" "logdemo" {
  name                = "logdemo-machine"
  resource_group_name = azurerm_resource_group.logdemo.name
  location            = azurerm_resource_group.logdemo.location
  size                = "Standard_B4ms"
  admin_username      = "adminuser"
  admin_password      = random_password.vmpassword.result
  network_interface_ids = [
    azurerm_network_interface.logdemo.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
  tags = local.tags

  depends_on = [azurerm_resource_group.logdemo]

}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.logdemo.id
  location           = azurerm_windows_virtual_machine.logdemo.location
  enabled            = true

  daily_recurrence_time = "2100"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
  tags = local.tags

}

#Agent for Windows
resource "azurerm_virtual_machine_extension" "mmaagent" {
  name                       = "mmaagent"
  virtual_machine_id         = azurerm_windows_virtual_machine.logdemo.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = "true"
  settings                   = <<SETTINGS
    {
      "workspaceId" : "${azurerm_log_analytics_workspace.logdemo.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${azurerm_log_analytics_workspace.logdemo.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

# Dependency Agent for Windows
resource "azurerm_virtual_machine_extension" "da" {
  name                       = "DAExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.logdemo.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

}