
resource "azurerm_network_interface" "nic" {
  count               = var.node_count
  name                = "${var.vmname}${format("%02d", count.index)}NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
