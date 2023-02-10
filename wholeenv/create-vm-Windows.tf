
resource "azurerm_network_interface" "nic" {
  count               = var.node_count
  name                = "${var.winvmname}${format("%02d", count.index)}NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "vm" {
  count      = var.node_count
  name       = "${var.winvmname}${format("%02d", count.index)}"
  depends_on = [azurerm_key_vault.kv1]

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmsize
  admin_username      = var.adminUsername
  admin_password      = azurerm_key_vault_secret.vmpassword.value

  tags = local.tags

  network_interface_ids = [
    element(azurerm_network_interface.nic.*.id, count.index),
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.winvmname}${format("%02d", count.index)}OSDISK"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.vmsku
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  count              = var.node_count
  virtual_machine_id = azurerm_windows_virtual_machine.vm[count.index].id
  location           = azurerm_windows_virtual_machine.vm[count.index].location
  enabled            = false

  daily_recurrence_time = "0000"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}

#Agent for Windows
resource "azurerm_virtual_machine_extension" "mmaagent" {
  count                      = var.node_count
  name                       = "mmaagent"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = "true"
  settings                   = <<SETTINGS
    {
      "workspaceId" : "${azurerm_log_analytics_workspace.law.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey" : "${azurerm_log_analytics_workspace.law.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

# Dependency Agent for Windows
resource "azurerm_virtual_machine_extension" "da" {
  count                      = var.node_count
  name                       = "DAExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true

}