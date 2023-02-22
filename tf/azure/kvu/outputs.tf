output "key_vault_name" {
  value = azurerm_key_vault.keyvault.name
}

output "apim_certificate_name" {
  value = azurerm_key_vault_certificate.apim_certificate.name
}

output "cert_url" {
  sensitive = true
  value = "${data.azurerm_storage_account.devops_sa.primary_blob_endpoint}/${var.cert_container_name}/${var.cert_name}?${data.azurerm_storage_account_blob_container_sas.sa_cert_sas.sas}"
}