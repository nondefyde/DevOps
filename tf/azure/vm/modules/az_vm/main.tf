data "template_file" "vm_init" {
  template = file(var.cloud_init_file)
  vars     = {
    prefix = var.prefix
    user   = var.admin_username
  }
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.prefix}-group"
  }
  byte_length = 2
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
  name                            = "${var.prefix}-${var.name}-vm-${count.index}"
  availability_set_id             = azurerm_availability_set.vm_avset.id
  resource_group_name             = var.group
  location                        = var.location
  size                            = var.disk_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [element(azurerm_network_interface.vm_network_interface.*.id, count.index)]

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

data "azurerm_private_dns_zone" "dns_zone" {
  name                = var.apim_domain
  resource_group_name = "${var.prefix}-group"
}

resource "azurerm_private_dns_a_record" "api_dns_record" {
  count               = var.vm_count
  name                = "${var.name}-${count.index}"
  zone_name           = data.azurerm_private_dns_zone.dns_zone.name
  resource_group_name = "${var.prefix}-group"
  ttl                 = 3600
  records             = element(azurerm_linux_virtual_machine.vm.*.private_ip_addresses, count.index)
}