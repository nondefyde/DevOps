# Manages the MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql_server" {
  location                     = var.location
  name                         = "${var.prefix}_mysqlfs-${var.service}"
  resource_group_name          = "${var.prefix}-group"
  administrator_login          = var.admin_username
  administrator_password       = var.admin_password
  backup_retention_days        = 7
  delegated_subnet_id          = azurerm_subnet.mysql_subnet.id
  geo_redundant_backup_enabled = false
  private_dns_zone_id          = azurerm_private_dns_zone.mysql_private_dns_zone.id
  sku_name                     = "GP_Standard_D2ds_v4"
  version                      = "8.0.21"
  zone                         = "1"

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }
  storage {
    iops    = 360
    size_gb = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.mysql_dns_zone_vnl]
}

# Manages the MySQL Flexible Server Database
resource "azurerm_mysql_flexible_database" "mysql_database" {
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
  name                = "${var.prefix}_mysqlfsdb_${var.service}"
  resource_group_name = "${var.prefix}-group"
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
}