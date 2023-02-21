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

data "azurerm_key_vault" "keyvault" {
  name                = "${var.prefix}vault"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-cert"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_api_management" "apim" {
  name                 = "${var.prefix}-api"
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  publisher_name       = var.publisher_name
  publisher_email      = var.publisher_email
  sku_name             = "${var.sku}_${var.capacity}"
  virtual_network_type = "Internal"

  identity {
    type = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.apim_subnets.id
  }
}


resource "azurerm_api_management_custom_domain" "apim_custom_domain" {
  api_management_id = azurerm_api_management.apim.id

  gateway {
    host_name    = "api.${var.apim_domain}"
    key_vault_id = data.azurerm_key_vault_certificate.apim_certificate.secret_id
  }

  developer_portal {
    host_name    = "portal.${var.apim_domain}"
    key_vault_id = data.azurerm_key_vault_certificate.apim_certificate.secret_id
  }

  depends_on = [azurerm_api_management.apim]
}