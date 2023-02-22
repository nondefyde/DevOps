output "key_vault_name" {
  value = azurerm_key_vault.keyvault.name
}

#output "apim_certificate_name" {
#  value = azurerm_key_vault_certificate.apim_certificate.name
#}

output "cert_filename" {
  value = data.local_sensitive_file.cert.filename
}

output "cert" {
  sensitive = true
  value = data.local_sensitive_file.cert.content
}