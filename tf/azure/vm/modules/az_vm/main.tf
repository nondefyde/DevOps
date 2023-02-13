# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.prefix}-${var.name}-group"
  }
  byte_length = 4
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "vm_storage_account" {
  name                     = "${var.prefix}diag${random_id.random_id.hex}"
  location                 = var.location
  resource_group_name      = "${var.prefix}-group"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.vm_count
  name                            = "${var.prefix}-${var.name}-vm-${count.index + 1}"
  availability_set_id             = azurerm_availability_set.vm_avset.id
  resource_group_name             = var.group
  location                        = var.location
  size                            = var.disk_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [element(azurerm_network_interface.vm_network_interface.*.id, count.index)]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.vm_storage_account.primary_blob_endpoint
  }

  tags = {
    environment = var.environment
  }
}

resource "null_resource" "install_dep" {
  count = var.vm_count
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = element(azurerm_network_interface.vm_network_interface.*.private_ip_address, count.index)
      user     = element(azurerm_linux_virtual_machine.vm.*.admin_username, count.index)
      password = element(azurerm_linux_virtual_machine.vm.*.admin_password, count.index)
    }

    inline = [
      "chmod +x ${var.cloud_init_file}",
      "${var.cloud_init_file} ${var.admin_username}"
    ]
  }
  depends_on = [azurerm_linux_virtual_machine.vm]
}