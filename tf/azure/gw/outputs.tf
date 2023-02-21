output "gw_name" {
  value = azurerm_application_gateway.gw_network.name
}

output "certificate_data" {
  value = data.azurerm_key_vault_certificate.apim_certificate.certificate_data
}