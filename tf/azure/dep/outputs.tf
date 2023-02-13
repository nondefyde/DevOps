output "virtual_network_name" {
  value = azurerm_virtual_network.app_virtual_network.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.app_virtual_network.id
}

output "virtual_subnet_name" {
  value = azurerm_subnet.app_virtual_subnet.name
}

output "virtual_subnet_id" {
  value = azurerm_subnet.app_virtual_subnet.id
}

output "network_security_group_id" {
  value = azurerm_network_security_group.vm_security_group.id
}

output "network_security_group_association_id" {
  value = azurerm_subnet_network_security_group_association.nsg-assoc.id
}