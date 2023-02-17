output "gw_name" {
  value = data.azurerm_application_gateway.gw_network.name
}

output "azurerm_network_interfaces" {
  value = data.azurerm_network_interface.net_interface
}

output "backend_address_pools" {
  value = data.azurerm_application_gateway.gw_network.backend_address_pool
}

output "backend_pool" {
  value = local.backend_pool
}

output "network_interface_application_gateway_backend_address_pool_id" {
  value = azurerm_network_interface_application_gateway_backend_address_pool_association.nic-assoc.*.backend_address_pool_id
}
