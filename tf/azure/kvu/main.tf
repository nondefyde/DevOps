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

data "azurerm_storage_account" "devops_sa" {
  name                = var.devops_sa
  resource_group_name = var.devops_sa_rg
}

data "azurerm_storage_blob" "devops_container" {
  name                   = "exampleblob"
  storage_account_name   = data.azurerm_storage_account.devops_sa.name
  storage_container_name = var.cert_container_name

  depends_on = [data.azurerm_storage_account.devops_sa]
}

data "azurerm_storage_account_blob_container_sas" "sa_cert_sas" {
  connection_string = data.azurerm_storage_account.devops_sa.primary_connection_string
  container_name    = var.cert_container_name
  https_only        = true

  ip_address = "168.1.5.65"

  start  = "2018-03-21"
  expiry = "2018-03-21"

  permissions {
    read   = true
    add    = true
    create = false
    write  = false
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"

  depends_on = [data.azurerm_storage_account.devops_sa]
}

data "http" "cert_file" {
  url = "${data.azurerm_storage_account.devops_sa.primary_blob_endpoint}/${var.cert_container_name}/${var.cert_name}?${data.azurerm_storage_account_blob_container_sas.sa_cert_sas.sas}"
}

resource "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-cert"
  key_vault_id = azurerm_key_vault.keyvault.id

  certificate {
    contents = base64decode(data.http.cert_file.response_body)
    password = var.cert_password
  }
  depends_on = [azurerm_key_vault_access_policy.vault_policy, data.azurerm_storage_blob.devops_container]
}

resource "azurerm_key_vault_secret" "public_key_secret" {
  name         = "${var.prefix}-apim-public-key"
  value        = azurerm_key_vault_certificate.apim_certificate.certificate_data
  key_vault_id = azurerm_key_vault.keyvault.id
}