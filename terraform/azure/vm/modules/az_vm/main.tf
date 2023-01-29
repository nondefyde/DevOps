# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.prefix}-group"
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

# Create (and display) an SSH key
resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "vm_init" {
  template = file(var.cloud_init_file)
  vars     = {
    prefix               = var.prefix
    user                 = var.admin_username
  }
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = "${var.prefix}-group"
  location                        = var.location
  size                            = var.disk_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [
    azurerm_network_interface.vm_network_interface.id,
  ]

  custom_data = base64encode(data.template_file.vm_init.rendered)

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