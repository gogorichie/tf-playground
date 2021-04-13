provider "azurerm" {
  features {}
}

data "azurerm_subnet" "subnet" {
  name                 = "websn01"
  virtual_network_name = "prd-use2-xrm-spoke-vnet"
  resource_group_name  = "prd-use2-xrm-spoke-rg"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vmname}20NIC"
  location            = var.location
  resource_group_name = data.azurerm_subnet.subnet.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.vmname}-20"
  resource_group_name   = data.azurerm_subnet.subnet.resource_group_name
  location              = var.location
  size                  = var.vmsize
  admin_username        = var.adminUsername
  admin_password        = var.adminPassword
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.vmname}20OSDISK"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.vmsku
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  location           = azurerm_windows_virtual_machine.vm.location
  enabled            = true

  daily_recurrence_time = "2100"
  timezone              = "Central Standard Time"

  notification_settings {
    enabled = false
  }
}

#####################
