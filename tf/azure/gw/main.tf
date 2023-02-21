data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "gw_subnet" {
  name                 = "${var.prefix}-gway-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_private_dns_zone" "dns_zone" {
  name                = var.apim_domain
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault" "keyvault" {
  name                = "${var.prefix}vault"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_certificate" "apim_certificate" {
  name         = "${var.prefix}-apim-cert"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "apim_public_key" {
  name         = "${var.prefix}-apim-public-key"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_public_ip" "gw_ip" {
  name                = "${var.prefix}-gw-pip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  api_suffixes                   = toset(split(",", var.api_suffixes))
  api_names                       = split(",", var.api_suffixes)
  frontend_port_name             = "${var.prefix}-gw-feport"
  frontend_ip_configuration_name = "${var.prefix}-gw-feip"
}

resource "azurerm_application_gateway" "gw_network" {
  name                = "${var.prefix}-app-gateway"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  gateway_ip_configuration {
    name      = "${var.prefix}-gw-ip-configuration"
    subnet_id = data.azurerm_subnet.gw_subnet.id
  }

  frontend_port {
    name = "${var.prefix}-80"
    port = 80
  }

  frontend_port {
    name = "${var.prefix}-443"
    port = 443
  }


  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.gw_ip.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.private_ip
  }


  ////////////////////////////////// APIM SETUPS ///////////////////////////////////
  http_listener {
    name                           = "${var.prefix}-apim-http-listener"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "${var.prefix}-443"
    protocol                       = "Https"
    ssl_certificate_name           = data.azurerm_key_vault_certificate.apim_certificate.name
  }

  backend_http_settings {
    name                  = "${var.prefix}-backend-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Https"
    request_timeout       = 60

#    authentication_certificate {
#      name = data.azurerm_key_vault_certificate.apim_certificate.name
#    }
  }

#  authentication_certificate {
#    name = data.azurerm_key_vault_certificate.apim_certificate.name
#    data = data.azurerm_key_vault_certificate.apim_certificate.certificate_data
#  }

  ssl_certificate {
    name                = data.azurerm_key_vault_certificate.apim_certificate.name
    key_vault_secret_id = data.azurerm_key_vault_certificate.apim_certificate.id
  }

  backend_address_pool {
    name  = "${var.prefix}-apim-pool"
    fqdns = [
      "api.stmapi.com"
    ]
  }

  backend_address_pool {
    name = "${var.prefix}-sink-pool"
  }

  request_routing_rule {
    name                       = "${var.prefix}-apim-rule"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "${var.prefix}-apim-http-listener"
    backend_address_pool_name  = "${var.prefix}-apim-sink-pool"
    backend_http_settings_name = "${var.prefix}-backend-setting"
    url_path_map_name          = "${var.prefix}-apim-url-path-map"
    priority                   = 100
  }

  url_path_map {
    name                               = "${var.prefix}-apim-url-path-map"
    default_backend_address_pool_name  = "${var.prefix}-sink-pool"
    default_backend_http_settings_name = "${var.prefix}-backend-setting"
    dynamic "path_rule" {
      for_each = local.api_suffixes
      content {
        name                       = "${split(":", path_rule.value)[0]}-apim-url-path-rule"
        backend_address_pool_name  = "${var.prefix}-apim-pool"
        backend_http_settings_name = "${var.prefix}-backend-setting"
        paths                      = [
          "/${split(":", path_rule.value)[1]}/*",
        ]
      }
    }
  }


  ////////////////////////////////// APIM SETUPS ENDS /////////////////////////////////////////

#
#
#  dynamic "http_listener" {
#    for_each = local.api_suffixes
#    content {
#      name                           = "${split(":", http_listener.value)[0]}-listener"
#      frontend_ip_configuration_name = local.frontend_ip_configuration_name
#      frontend_port_name             = local.frontend_port_name
#      protocol                       = "Http"
#      host_name                      = "${split(":", http_listener.value)[1]}.${var.apim_domain}"
#      ssl_certificate_name = data.azurerm_key_vault_certificate.apim_certificate.name
#    }
#  }
#
#  dynamic "backend_http_settings" {
#    for_each = local.api_suffixes
#    content {
#      name                  = "${split(":", backend_http_settings.value)[0]}-http-setting"
#      cookie_based_affinity = "Disabled"
#      port                  = 8000
#      path                  = "/"
#      protocol              = "Http"
#      request_timeout       = 60
#    }
#  }
#
#  dynamic "backend_address_pool" {
#    for_each = local.api_suffixes
#    content {
#      name = "${split(":", backend_address_pool.value)[0]}-pool"
#    }
#  }
#
#  dynamic "request_routing_rule" {
#    for_each = local.api_suffixes
#    content {
#      name                       = "${split(":", request_routing_rule.value)[0]}-routing-tb"
#      rule_type                  = "Basic"
#      http_listener_name         = "${split(":", request_routing_rule.value)[0]}-listener"
#      backend_address_pool_name  = "${split(":", request_routing_rule.value)[0]}-pool"
#      backend_http_settings_name = "${split(":", request_routing_rule.value)[0]}-http-setting"
#      priority                   = 100
#    }
#  }
}

resource "azurerm_private_dns_a_record" "api_dns_record" {
  count               = length(local.api_names)
  name                = "${split(":", local.api_names[count.index])[1]}.${var.apim_domain}"
  zone_name           = data.azurerm_private_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 3600
  records             = [var.private_ip]

  depends_on = [azurerm_application_gateway.gw_network]
}