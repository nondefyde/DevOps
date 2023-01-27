output "mysql_server_zone" {
  value     = azurerm_mysql_flexible_server.mysql_server.zone
}

output "mysql_server_connection" {
  value     = azurerm_mysql_flexible_server.mysql_server.connection
}

output "mysql_server_name" {
  value     = azurerm_mysql_flexible_server.mysql_server.name
}

output "mysql_server_fqdn" {
  value     = azurerm_mysql_flexible_server.mysql_server.fqdn
}

output "mysql_database_name" {
  value = azurerm_mysql_flexible_database.mysql_database.name
}

output "mysql_database_server_name" {
  value = azurerm_mysql_flexible_database.mysql_database.server_name
}