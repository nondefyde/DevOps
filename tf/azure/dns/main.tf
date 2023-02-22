data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.prefix}vault"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = var.tenant_id
  sku_name            = "premium"
}

resource "azurerm_key_vault_access_policy" "vault_policy" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update",
  ]
  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]
  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}

resource "null_resource" "openssl" {
  provisioner "local-exec" {
    command = <<EOT
      echo ${var.cert_key} > cert.key
      echo ${var.cert} > cert.pem
      openssl pkcs12 -export -out cert.pfx -inkey cert.key -in cert.pem -passout pass:${var.cert_password}
    EOT
  }
}

resource "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-cert"
  key_vault_id = azurerm_key_vault.keyvault.id

  certificate {
    contents = filebase64("cert.pfx")
    password = var.cert_password
  }
  depends_on = [azurerm_key_vault_access_policy.vault_policy]
}

resource "azurerm_key_vault_secret" "public_key_secret" {
  name         = "${var.prefix}-apim-public-key"
  value        = azurerm_key_vault_certificate.apim_certificate.certificate_data
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = var.apim_domain
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${var.prefix}-network-link"
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name

  depends_on = [azurerm_private_dns_zone.dns_zone]
}