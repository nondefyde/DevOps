output "gw_name" {
  value = azurerm_application_gateway.gw_network.name
}

output "azurerm_network_interfaces" {
  value = data.azurerm_network_interface.net_interface
}

output "backend_address_pools" {
  value = azurerm_application_gateway.gw_network.backend_address_pool
}