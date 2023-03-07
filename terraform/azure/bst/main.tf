data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "baston_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.address_prefix]
}

resource "azurerm_public_ip" "baston_public_ip" {
  name                = "${var.prefix}-baston-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "baston_host" {
  name                   = "${var.prefix}-baston-host"
  location               = data.azurerm_resource_group.rg.location
  resource_group_name    = data.azurerm_resource_group.rg.name
  sku                    = var.sku
  shareable_link_enabled = var.shareable_link_enabled

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.baston_subnet.id
    public_ip_address_id = azurerm_public_ip.baston_public_ip.id
  }
}