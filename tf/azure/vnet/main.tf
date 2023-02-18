data "azurerm_resource_group" "rg" {
  name = var.group
}

resource "azurerm_virtual_network" "app_virtual_network" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "app_virtual_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app_virtual_network.name
  address_prefixes     = [var.address_prefix]
}

resource "azurerm_network_security_group" "vm_security_group" {
  name                = "${var.prefix}-net-sec-group"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

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

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  subnet_id                 = azurerm_subnet.app_virtual_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_security_group.id
}


resource "azurerm_subnet" "baston_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app_virtual_network.name
  address_prefixes     = ["10.0.2.0/27"]
}

resource "azurerm_public_ip" "baston_public_ip" {
  name                = "${var.prefix}-baston-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "baston_host" {
  name                = "${var.prefix}-baston-host"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.baston_subnet.id
    public_ip_address_id = azurerm_public_ip.baston_public_ip.id
  }
}