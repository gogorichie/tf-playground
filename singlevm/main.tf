provider "azurerm" {
  features {}
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.resourcegroup
}

resource "azurerm_network_interface" "nic" {
  count               = var.node_count
  name                = "${var.vmname}${format("%02d", count.index)}NIC"
  location            = var.location
  resource_group_name = var.resourcegroup

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.node_count
  name                = "${var.vmname}-${format("%02d", count.index)}"
  resource_group_name = var.resourcegroup
  location            = var.location
  size                = var.vmsize
  admin_username      = var.adminUsername
  admin_password      = var.adminPassword
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
  enabled            = true

  daily_recurrence_time = "2200"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled         = false
  }
}
