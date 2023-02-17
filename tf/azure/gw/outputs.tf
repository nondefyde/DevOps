output "gw_name" {
  value = azurerm_application_gateway.gw_network.name
}

output "backend_address_pools" {
  value = azurerm_application_gateway.gw_network.backend_address_pool
}