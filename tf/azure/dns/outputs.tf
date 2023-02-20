output "key_vault_name" {
  value = azurerm_key_vault.keyvault.name
}

output "apim_certificate_name" {
  value = azurerm_key_vault_certificate.apim_certificate.name
}

output "object_id" {
  value = data.azurerm_client_config.current.object_id
}

output "principal_id" {
  value = data.azurerm_api_management.apim.identity[0].principal_id
}