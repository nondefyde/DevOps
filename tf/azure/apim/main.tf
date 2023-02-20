data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "apim_subnets" {
  name                 = "${var.prefix}-apim-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

resource "azurerm_api_management" "apim" {
  name                 = "${var.prefix}-api"
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  sku_name             = "${var.sku}_${var.capacity}"
  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.apim_subnets.id
  }
}

resource "azurerm_key_vault" "apim_keyvault" {
  name                = "${var.prefix}-apim-keyvault"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

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
}

resource "azurerm_key_vault_certificate_issuer" "apim_issuer" {
  name         = "${var.prefix}-apim-issuer"
  key_vault_id = azurerm_key_vault.apim_keyvault.id
  account_id   = var.account_id
  password     = var.admin_password
}

resource "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-certificate"
  key_vault_id = azurerm_key_vault.apim_keyvault.id
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

      subject            = "CN=${var.custom_domain}"
      validity_in_months = 12

      subject_alternative_names {
        dns_names = [
          "api-${var.custom_domain}",
          "portal-${var.custom_domain}"
        ]
      }
    }
  }
}

resource "azurerm_api_management_custom_domain" "example" {
  api_management_id = azurerm_api_management.apim.id

  gateway {
    host_name    = "api-${var.custom_domain}"
    key_vault_id = azurerm_key_vault_certificate.apim_certificate.secret_id
  }

  developer_portal {
    host_name    = "portal-${var.custom_domain}"
    key_vault_id = azurerm_key_vault_certificate.apim_certificate.secret_id
  }
}