# Manages the Virtual Network
resource "azurerm_virtual_network" "mysql_vpn" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = "vnet-${var.service}"
  resource_group_name = "${var.prefix}-group"
}

# Manages the Subnet
resource "azurerm_subnet" "mysql_subnet" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "${var.prefix}_mysqlsubnet-${var.service}"
  resource_group_name  = "${var.prefix}-group"
  virtual_network_name = azurerm_virtual_network.mysql_vpn.name
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Enables you to manage Private DNS zones within Azure DNS
resource "azurerm_private_dns_zone" "mysql_private_dns_zone" {
  name                = "${var.service}.mysql.database.azure.com"
  resource_group_name = "${var.prefix}-group"
}

# Enables you to manage Private DNS zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_zone_vnl" {
  name                  = "${var.prefix}_mysqlfsVnetZone${var.service}.com"
  private_dns_zone_name = azurerm_private_dns_zone.mysql_private_dns_zone.name
  resource_group_name   = "${var.prefix}-group"
  virtual_network_id    = var.vpn_id
}