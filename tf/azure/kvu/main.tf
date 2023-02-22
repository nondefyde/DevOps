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
    "Purge"
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

resource "random_id" "refresh" {
  keepers = {
    trigger_flag = var.trigger_flag
  }
  byte_length = 2
}

resource "local_sensitive_file" "cert_pem" {
  content  = var.cert
  filename = "${path.module}/cert.pem"
}

resource "local_sensitive_file" "cert_key" {
  content  = var.cert_key
  filename = "${path.module}/cert.key"
}

resource "null_resource" "openssl" {
  triggers = {
    refresh = random_id.refresh.hex
  }
  provisioner "local-exec" {
    command = "openssl pkcs12 -export -out ${path.module}/cert.pfx -inkey ${path.module}/${local_sensitive_file.cert_key.filename} -in ${path.module}/${local_sensitive_file.cert_pem.filename} -passout pass:${var.cert_password}"
  }
  depends_on = [
    local_sensitive_file.cert_pem,
    local_sensitive_file.cert_key
  ]
}

data "local_sensitive_file" "cert" {
  filename = "${path.module}/cert.pfx"
  depends_on = [null_resource.openssl]
}

resource "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-cert"
  key_vault_id = azurerm_key_vault.keyvault.id

  certificate {
    contents = data.local_sensitive_file.cert.content_base64
    password = var.cert_password
  }
  depends_on = [azurerm_key_vault_access_policy.vault_policy, data.local_sensitive_file.cert]
}

resource "azurerm_key_vault_secret" "public_key_secret" {
  name         = "${var.prefix}-apim-public-key"
  value        = azurerm_key_vault_certificate.apim_certificate.certificate_data
  key_vault_id = azurerm_key_vault.keyvault.id
}