resource "azurerm_virtual_network" "vm_network" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = "${var.prefix}-group"
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = "${var.prefix}-group"
  virtual_network_name = azurerm_virtual_network.vm_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-public-id"
  resource_group_name = "${var.prefix}-group"
  location            = var.location
  allocation_method   = "Static"
  ip_version          = "IPv4"
  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface" "vm_network_interface" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = "${var.prefix}-group"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_security_group" "vm_security_group" {
  name                = "${var.prefix}-net-sec-group"
  location            = var.location
  resource_group_name = "${var.prefix}-group"

  security_rule {
    name                       = "sub-domains"
    priority                   = 100
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