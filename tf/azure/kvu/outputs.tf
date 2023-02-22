output "key_vault_name" {
  value = azurerm_key_vault.keyvault.name
}

output "apim_certificate_name" {
  value = azurerm_key_vault_certificate.apim_certificate.name
}