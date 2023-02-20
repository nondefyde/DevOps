data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "apim_subnets" {
  name                 = "${var.prefix}-apim-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

resource "azurerm_network_security_group" "apim_security_group" {
  name                = "${var.prefix}-apim-net-group"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "${var.prefix}-apim-inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "${var.prefix}-apim-outbound"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [data.azurerm_subnet.apim_subnets]
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  subnet_id                 = data.azurerm_subnet.gw_subnets.id
  network_security_group_id = azurerm_network_security_group.apim_security_group.id
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
    subnet_id = data.azurerm_subnet.apim_subnets.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.nsg-assoc]
}