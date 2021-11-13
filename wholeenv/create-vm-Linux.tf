
resource "azurerm_network_interface" "linuxnic" {
  count               = var.node_count
  name                = "${var.linuxvmname}${format("%02d", count.index)}NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "linuxvm" {
  count                           = var.node_count
  name                            = "${var.linuxvmname}${format("%02d", count.index)}"
  depends_on                      = [azurerm_key_vault.kv1]
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vmsize
  admin_username                  = var.adminUsername
  admin_password                  = azurerm_key_vault_secret.vmpassword.value
  disable_password_authentication = "false"
  tags                            = local.tags

  provision_vm_agent = "true"
  network_interface_ids = [
    element(azurerm_network_interface.linuxnic.*.id, count.index),
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.linuxvmname}${format("%02d", count.index)}OSDISK"

  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "linuxshutdown" {
  count              = var.node_count
  virtual_machine_id = azurerm_linux_virtual_machine.linuxvm[count.index].id
  location           = azurerm_linux_virtual_machine.linuxvm[count.index].location
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
#   target_resource_id         = azurerm_linux_virtual_machine.linuxvm[count.index].id
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
