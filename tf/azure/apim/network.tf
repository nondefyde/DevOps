resource "azurerm_network_interface" "vm_network_interface" {
  name                = "${var.prefix}-net"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.group

  ip_configuration {
    name                          = "${var.prefix}-internal"
    subnet_id                     = data.azurerm_subnet.subnets[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "vm_security_group" {
  name                = "${var.prefix}-net-sec-group"
  location            = data.azurerm_resource_group.rg.location
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
  network_interface_id      = azurerm_network_interface.vm_network_interface.id
  network_security_group_id = azurerm_network_security_group.vm_security_group.id
}