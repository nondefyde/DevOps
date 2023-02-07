output "app_virtual_network_name" {
  value = azurerm_virtual_network.app_virtual_network.name
}

output "app_virtual_network_id" {
  value = azurerm_virtual_network.app_virtual_network.id
}

output "app_virtual_subnet_name" {
  value = azurerm_subnet.app_virtual_subnet.name
}

output "app_virtual_subnet_id" {
  value = azurerm_subnet.app_virtual_subnet.id
}