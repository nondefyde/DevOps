resource "azurerm_resource_group" "vm_group" {
  name     = "${var.app_group}-group"
  location = var.location
}


# Generate random value for the name
resource "random_string" "name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

# Generate random value for the login password
resource "random_password" "password" {
  length           = 8
  lower            = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}


# Manages the MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql_server" {
  location                     = var.location
  name                         = "${var.prefix}-mysqlfs-${var.service}"
  resource_group_name          = azurerm_resource_group.vm_group.name
  administrator_login          = var.admin_username
  administrator_password       = random_password.password.result
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
  name                = "${var.prefix}-mysqlfsdb-${var.service}"
  resource_group_name = azurerm_resource_group.vm_group.name
  server_name         = azurerm_mysql_flexible_server.mysql_server.name
}