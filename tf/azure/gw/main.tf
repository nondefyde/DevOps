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
  name                = var.vault_name
  resource_group_name = var.vault_rg
}

data "azurerm_key_vault_certificate" "ssl_certificate" {
  name         = var.cert_name
  key_vault_id = data.azurerm_key_vault.keyvault.id
  depends_on = [azurerm_key_vault_access_policy.vault_policy]
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
    name                          = "${var.prefix}-gw-private-ip"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
    subnet_id = data.azurerm_subnet.gw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-gw-public-ip"
    public_ip_address_id = azurerm_public_ip.gw_ip.id
  }

  ////////////////////////////////// APIM SETUPS ///////////////////////////////////
  http_listener {
    name                           = "${var.prefix}-apim-http-listener"
    frontend_ip_configuration_name = "${var.prefix}-gw-public-ip"
    frontend_port_name             = "${var.prefix}-80"
    protocol                       = "Http"
#    ssl_certificate_name           = data.azurerm_key_vault_certificate.apim_certificate.name
  }

  backend_http_settings {
    name                  = "${var.prefix}-backend-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60

#    authentication_certificate {
#      name = data.azurerm_key_vault_certificate.apim_certificate.name
#    }
  }

#  authentication_certificate {
#    name = data.azurerm_key_vault_certificate.apim_certificate.name
#    data = data.azurerm_key_vault_certificate.apim_certificate.certificate_data
#  }

#  ssl_certificate {
#    name                = data.azurerm_key_vault_certificate.apim_certificate.name
#    data                = data.azurerm_key_vault_certificate.apim_certificate.certificate_data_base64
#    password            = "password"
#  }

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
    priority                   = 10
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
          "/${split(":", path_rule.value)[1]}/*"
        ]
      }
    }
  }


  ////////////////////////////////// APIM SETUPS ENDS /////////////////////////////////////////


  ////////////////////////////////// BACKEND SETUPS /////////////////////////////////////////

  dynamic "http_listener" {
    for_each = local.api_suffixes
    content {
      name                           = "${split(":", http_listener.value)[0]}-internal-listener"
      frontend_ip_configuration_name = "${var.prefix}-gw-private-ip"
      frontend_port_name             = "${var.prefix}-80"
      protocol                       = "Http"
      host_name                      = "${split(":", http_listener.value)[1]}.${var.apim_domain}"
    }
  }

  dynamic "backend_address_pool" {
    for_each = local.api_suffixes
    content {
      name = "${split(":", backend_address_pool.value)[0]}-pool"
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.api_suffixes
    content {
      name                  = "${split(":", backend_http_settings.value)[0]}-http-setting"
      cookie_based_affinity = "Disabled"
      port                  = split(":", backend_http_settings.value)[2]
      path                  = "/"
      protocol              = "Http"
      request_timeout       = 60
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.api_suffixes
    content {
      name                       = "${split(":", request_routing_rule.value)[0]}-routing-tb"
      rule_type                  = "Basic"
      http_listener_name         = "${split(":", request_routing_rule.value)[0]}-internal-listener"
      backend_address_pool_name  = "${split(":", request_routing_rule.value)[0]}-pool"
      backend_http_settings_name = "${split(":", request_routing_rule.value)[0]}-http-setting"
      priority                   = split(":", request_routing_rule.value)[3]
    }
  }

  ////////////////////////////////// END BACKEND SETUPS /////////////////////////////////////////
}

resource "azurerm_private_dns_a_record" "api_dns_record" {
  count               = length(local.api_names)
  name                = "${split(":", local.api_names[count.index])[1]}"
  zone_name           = data.azurerm_private_dns_zone.dns_zone.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 3600
  records             = [var.private_ip]

  depends_on = [azurerm_application_gateway.gw_network]
}