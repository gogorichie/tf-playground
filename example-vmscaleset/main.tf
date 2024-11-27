resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "acctest-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_virtual_network" "vNet" {
  name                = var.vnetname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = var.snname
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                 = var.vmname
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  sku                  = var.vmsize
  instances            = 3
  admin_password       = var.adminPassword
  admin_username       = var.adminPassword
  computer_name_prefix = "vm-"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.vmsku
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }

  depends_on = [azurerm_log_analytics_workspace.law]
}

resource "azurerm_virtual_machine_scale_set_extension" "AzureMonitorWindowsAgent" {
  name                         = "AzureMonitorWindowsAgent"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.EnterpriseCloud.Monitoring"
  type                         = "OmsAgentForWindows"
  type_handler_version         = "1.13"

  settings = <<SETTINGS
{
    "workspaceId": "${azurerm_log_analytics_workspace.law.id}"
}
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
{
    "workspaceKey": "${azurerm_log_analytics_workspace.law.primary_shared_key}"
}
PROTECTED_SETTINGS
}