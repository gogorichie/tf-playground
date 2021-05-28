
resource "azurerm_network_interface" "nic" {
  count               = var.node_count
  name                = "${var.vmname}${format("%02d", count.index)}NIC"
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
  count               = var.node_count
  name                = "${var.vmname}-${format("%02d", count.index)}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmsize
  admin_username      = var.adminUsername
  admin_password      = var.adminPassword
  tags                = local.tags

  network_interface_ids = [
    element(azurerm_network_interface.nic.*.id, count.index),
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.vmname}${format("%02d", count.index)}OSDISK"
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

# resource "azurerm_monitor_diagnostic_setting" "nsg-diagnostics" {
#   count                      = var.node_count
#   name                       = "diag2law"
#   target_resource_id         = azurerm_windows_virtual_machine.vm[count.index].id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
#   log {
#     category = "NetworkSecurityGroupEvent"
#     enabled  = true
#   }
#   log {
#     category = "NetworkSecurityGroupRuleCounter"
#     enabled  = true
#   }
# }
