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

resource "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-cert"
  key_vault_id = azurerm_key_vault.keyvault.id
  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${var.apim_domain}"
      validity_in_months = 12

      subject_alternative_names {
        dns_names = [
          "*.${var.apim_domain}",
          "api.${var.apim_domain}",
          "portal.${var.apim_domain}"
        ]
      }
    }
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

resource "azurerm_private_dns_virtual_network_link" "example" {
  name                  = "${var.prefix}-network-link"
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name

  depends_on = [azurerm_private_dns_zone.dns_zone]
}