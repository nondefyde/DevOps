output "baston_id" {
  value = azurerm_bastion_host.baston_host.id
}

output "baston_dns" {
  value = azurerm_bastion_host.baston_host.dns_name
}