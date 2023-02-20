data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_client_config" "current" {}

data "azurerm_api_management" "apim" {
  name                = "${var.prefix}-api"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "apim_dns_zone" {
  name                = var.apim_domain
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "api_dns_record" {
  name                = var.gateway_subdomain
  zone_name           = azurerm_private_dns_zone.apim_dns_zone.name
  resource_group_name = azurerm_private_dns_zone.apim_dns_zone.resource_group_name
  ttl                 = 3600
  records             = data.azurerm_api_management.apim.private_ip_addresses
}

resource "azurerm_private_dns_a_record" "portal_dns_record" {
  name                = var.portal_subdomain
  zone_name           = azurerm_private_dns_zone.apim_dns_zone.name
  resource_group_name = azurerm_private_dns_zone.apim_dns_zone.resource_group_name
  ttl                 = 3600
  records             = data.azurerm_api_management.apim.private_ip_addresses
}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.prefix}vault"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = var.tenant_id
  sku_name            = "premium"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
#    object_id = data.azurerm_client_config.current.object_id
    object_id = data.azurerm_api_management.apim.identity[0].principal_id

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

  depends_on = [
    azurerm_private_dns_a_record.api_dns_record,
    azurerm_private_dns_a_record.portal_dns_record
  ]
}

resource "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-certificate"
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

      subject            = "CN=*.${var.apim_domain}"
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
}

resource "azurerm_api_management_custom_domain" "apim_custom_domain" {
  api_management_id = data.azurerm_api_management.apim.id

  gateway {
    host_name    = "api.${var.apim_domain}"
    key_vault_id = azurerm_key_vault_certificate.apim_certificate.secret_id
  }

  developer_portal {
    host_name    = "portal.${var.apim_domain}"
    key_vault_id = azurerm_key_vault_certificate.apim_certificate.secret_id
  }
}

