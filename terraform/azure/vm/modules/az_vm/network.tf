resource "azurerm_network_interface" "vm_network_interface" {
  count                   = var.vm_count
  name                    = "${var.prefix}-${var.name}-net-${count.index}"
  location                = var.location
  resource_group_name     = var.group

  ip_configuration {
    name                          = "${var.prefix}-${var.name}-internal-${count.index}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_managed_disk" "vm_managed_disk" {
  count                = var.vm_count
  name                 = "${var.prefix}_${var.name}_datadisk_${count.index}"
  location             = var.location
  resource_group_name  = var.group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"
}

resource "azurerm_network_security_group" "vm_security_group" {
  count               = var.vm_count
  name                = "${var.prefix}-${var.name}-net-sec-group-${count.index}"
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

resource "azurerm_network_interface_security_group_association" "net_isga" {
  count                     = var.vm_count
  network_interface_id      = element(azurerm_network_interface.vm_network_interface.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.vm_security_group.*.id, count.index)
}