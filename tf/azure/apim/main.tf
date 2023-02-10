data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "apim_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.address_prefix]
}

resource "azurerm_network_security_group" "apim_security_group" {
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
  subnet_id                 = azurerm_subnet.apim_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_security_group.id
}


data "azurerm_subnet" "subnets" {
  name                 = data.azurerm_virtual_network.vnet.subnets[count.index]
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  count                = length(data.azurerm_virtual_network.vnet.subnets)
}

resource "azurerm_api_management" "apim" {
  name                = "${var.prefix}-api"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "${var.sku}_${var.capacity}"

  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.subnets[0].id
  }

  depends_on = [azurerm_subnet_network_security_group_association]
}