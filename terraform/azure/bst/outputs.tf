output "baston_id" {
  value = azurerm_bastion_host.baston_host.id
}

output "baston_ip" {
  value = azurerm_public_ip.baston_public_ip.ip_address
}

output "baston_dns" {
  value = azurerm_bastion_host.baston_host.dns_name
}