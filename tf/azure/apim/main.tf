data "azurerm_resource_group" "rg" {
  name = var.group
}

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
}

resource "azurerm_key_vault_certificate_issuer" "apim_issuer" {
  name         = "${var.prefix}-apim-issuer"
  key_vault_id = azurerm_key_vault.example_keyvault.id
  account_id   = var.account_id
  password     = var.admin_password
}

resource "azurerm_key_vault_certificate" "apim_certificate" {
  name               = "${var.prefix}-apim-certificate"
  key_vault_id       = azurerm_key_vault.example_keyvault.id
  certificate_type   = "application/x-pkcs12"
  subject            = "CN=${var.custom_domain}"
  validity_in_months = 12
  issuer_id          = azurerm_key_vault_certificate_issuer.example_issuer.id
}

resource "azurerm_api_management_custom_domain" "example_domain" {
  name                   = "${var.prefix}-apim-cust-domain"
  resource_group_name    = data.azurerm_resource_group.rg.name
  api_management_name    = azurerm_api_management.apim.name
  hostname               = var.custom_domain
  certificate_thumbprint = azurerm_key_vault_certificate.apim_certificate.thumbprint
  certificate_name       = azurerm_key_vault_certificate.apim_certificate.name
}