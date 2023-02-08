resource "azurerm_virtual_network" "app_virtual_network" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.group
}

resource "azurerm_subnet" "app_virtual_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.app_virtual_network.name
  address_prefixes     = [var.address_prefixes]
}