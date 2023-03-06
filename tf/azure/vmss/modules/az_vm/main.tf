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

resource "azurerm_network_security_group" "vm_security_group" {
  name                = "${var.prefix}-${var.name}-net-sec-group"
  location            = var.location
  resource_group_name = var.group

  security_rule {
    name                       = "sub-domains"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "vm_set" {
  name                            = "${var.prefix}-${var.name}-vms"
  resource_group_name             = var.group
  location                        = var.location
  sku                             = "Standard_F2"
  instances                       = var.vm_count
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

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

  network_interface {
    name                      = "${var.prefix}-${var.name}-net-interface"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.vm_security_group.id

    ip_configuration {
      name                          = "${var.prefix}-${var.name}-internal"
      subnet_id                     = var.subnet_id
      primary                       = true
      private_ip_address_allocation = "Dynamic"
    }
  }

  tags = {
    environment = var.environment
  }
}


data "azurerm_private_dns_zone" "dns_zone" {
  name                = var.base_domain
  resource_group_name = var.group
}

resource "azurerm_private_dns_a_record" "api_dns_record" {
  count               = var.vm_count
  name                = "${var.name}-${count.index}"
  zone_name           = data.azurerm_private_dns_zone.dns_zone.name
  resource_group_name = var.group
  ttl                 = 3600
  records             = [
    azurerm_linux_virtual_machine_scale_set.vm_set.virtual_machine_scale_set_instances[count.index].network_interface[0].ip_configuration[0].private_ip_address
  ]
}