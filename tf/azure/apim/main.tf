data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnets" {
  name                 = data.azurerm_virtual_network.vnet.subnets[count.index]
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  count                = length(data.azurerm_virtual_network.vnet.subnets)
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-public-id"
  resource_group_name = "${var.prefix}-group"
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  ip_version          = "IPv4"
  domain_name_label   = "${var.prefix}-dns"
  tags                = {
    environment = var.environment
  }
}

resource "azurerm_api_management" "apim" {
  name                = "${var.prefix}-api"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  public_ip_address_id = azurerm_public_ip.public_ip.id
  sku_name = "Developer_1"
  virtual_network_configuration = {
    subnet_id: data.azurerm_subnet.subnets[0].id
  }
}