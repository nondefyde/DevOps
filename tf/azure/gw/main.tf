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
  name                = var.base_domain
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault" "keyvault" {
  name                = var.vault_name
  resource_group_name = var.vault_rg
}

data "azurerm_key_vault_certificate" "ssl_certificate" {
  name         = var.cert_name
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_api_management" "apim" {
  name                = "${var.prefix}-api"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_public_ip" "gw_ip" {
  name                = "${var.prefix}-gw-pip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_user_assigned_identity" "appgw_identity" {
  name                = "${var.prefix}-gw-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location
}

resource "azurerm_key_vault_access_policy" "vault_policy" {
  key_vault_id = data.azurerm_key_vault.keyvault.id

  tenant_id = azurerm_user_assigned_identity.appgw_identity.tenant_id
  object_id = azurerm_user_assigned_identity.appgw_identity.principal_id

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
    "Update"
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
    "WrapKey"
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  api_suffixes                   = toset(split(",", var.api_suffixes))
  api_names                      = split(",", var.api_suffixes)
  frontend_port_name             = "gw-feport"
  frontend_ip_configuration_name = "gw-feip"

  http_frontend_port_name         = "port-80"
  http_frontend_port_name_service = "port-8000"
  https_frontend_port_name        = "port-443"

  gw_public_ip  = "${var.prefix}-gw-public-ip"
  gw_private_ip = "${var.prefix}-gw-private-ip"

  apim_http_setting         = "apim-http-listener"
  apim_backend_setting      = "apim-backend-setting"
  apim_backend_ping_setting = "apim-backend-ping-setting"
  apim_backend_pool         = "apim-pool"
  apim_url_path_map_name    = "apim-url-path-map"
  apim_routing_rule         = "apim-rule"

  portal_http_setting    = "portal-http-setting"
  portal_backend_setting = "portal-backend-setting"
  portal_backend_pool    = "portal-pool"
  portal_routing_rule    = "portal-rule"

  ping_pool = "apis-pool"
  fqdns     = [for prefix in local.api_names : "${prefix}.${var.base_domain}"]
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

  identity {
    type               = "UserAssigned"
    identity_ids       = [azurerm_user_assigned_identity.appgw_identity.id]
  }

  gateway_ip_configuration {
    name      = "gw-ip-configuration"
    subnet_id = data.azurerm_subnet.gw_subnet.id
  }

  frontend_port {
    name = local.http_frontend_port_name
    port = 80
  }

  frontend_port {
    name = local.https_frontend_port_name
    port = 443
  }

  frontend_port {
    name = local.http_frontend_port_name_service
    port = 8000
  }

  frontend_ip_configuration {
    name                          = local.gw_private_ip
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
    subnet_id                     = data.azurerm_subnet.gw_subnet.id
  }

  frontend_ip_configuration {
    name                 = local.gw_public_ip
    public_ip_address_id = azurerm_public_ip.gw_ip.id
  }

  ssl_certificate {
    name                = data.azurerm_key_vault_certificate.ssl_certificate.name
    key_vault_secret_id = data.azurerm_key_vault_certificate.ssl_certificate.secret_id
  }

  ////////////////////////////////// APIM SETUPS ////////////////////////////////

  /// <<<<>>>> APIM SETUPS <<<<>>>> ////////
  http_listener {
    name                           = local.apim_http_setting
    frontend_ip_configuration_name = local.gw_public_ip
    frontend_port_name             = local.http_frontend_port_name
    protocol                       = "Http"
    host_name                      = "${var.api_subdomain}.${var.base_domain}"
  }

  /////////////////// Ping settings /////////////////////
  backend_http_settings {
    name                                = local.apim_backend_ping_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    path                                = "/ping"
    pick_host_name_from_backend_address = true
  }

  backend_address_pool {
    name     = local.ping_pool
    fqdns    = local.fqdns
  }
  //////////////////// Ping settings ///////////////////////

  backend_http_settings {
    name                                = local.apim_backend_setting
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
  }

  backend_address_pool {
    name  = local.apim_backend_pool
    fqdns = [
      "${var.gateway_subdomain}.${var.base_domain}"
    ]
  }

  request_routing_rule {
    name                       = local.apim_routing_rule
    rule_type                  = "PathBasedRouting"
    http_listener_name         = local.apim_http_setting
    backend_address_pool_name  = local.apim_backend_pool
    backend_http_settings_name = local.apim_backend_setting
    url_path_map_name          = local.apim_url_path_map_name
    priority                   = 10
  }

  url_path_map {
    name                               = local.apim_url_path_map_name
    default_backend_address_pool_name  = local.apim_backend_pool
    default_backend_http_settings_name = local.apim_backend_ping_setting
    dynamic "path_rule" {
      for_each = local.api_suffixes
      content {
        name                       = "${split(":", path_rule.value)[0]}-path-rule"
        backend_address_pool_name  = local.apim_backend_pool
        backend_http_settings_name = local.apim_backend_setting
        paths                      = [
          "/${split(":", path_rule.value)[1]}/*"
        ]
      }
    }
  }

  /// <<<<>>>> APIM SETUPS <<<<>>>> ////////

  /// <<<<>>>> APIM PORTAL SETUPS  <<<<>>>> ////////
  http_listener {
    name                                = local.portal_http_setting
    frontend_ip_configuration_name      = local.gw_public_ip
    frontend_port_name                  = local.http_frontend_port_name
    protocol                            = "Http"
    host_name                           = "${var.portal_subdomain}.${var.base_domain}"
  }

  backend_http_settings {
    name                           = local.portal_backend_setting
    cookie_based_affinity          = "Disabled"
    port                           = 443
    protocol                       = "Https"
    request_timeout                = 60
    pick_host_name_from_backend_address = true
  }

  backend_address_pool {
    name  = local.portal_backend_pool
    fqdns = [
      "${var.portal_subdomain}.${var.base_domain}"
    ]
  }

  request_routing_rule {
    name                       = local.portal_routing_rule
    rule_type                  = "Basic"
    http_listener_name         = local.portal_http_setting
    backend_address_pool_name  = local.portal_backend_pool
    backend_http_settings_name = local.portal_backend_setting
    priority                   = 11
  }
  ////////////////////////////////// APIM SETUPS ENDS /////////////////////////////////////////


  ////////////////////////////////// BACKEND SETUPS /////////////////////////////////////////

  dynamic "http_listener" {
    for_each = local.api_suffixes
    content {
      name                           = "${split(":", http_listener.value)[0]}-http-listener"
      frontend_ip_configuration_name = local.gw_private_ip
      frontend_port_name             = local.http_frontend_port_name_service
      protocol                       = "Http"
      host_name                      = "${split(":", http_listener.value)[1]}.${var.base_domain}"
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
      name                  = "${split(":", backend_http_settings.value)[0]}-backend-listener"
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
      http_listener_name         = "${split(":", request_routing_rule.value)[0]}-http-listener"
      backend_address_pool_name  = "${split(":", request_routing_rule.value)[0]}-pool"
      backend_http_settings_name = "${split(":", request_routing_rule.value)[0]}-backend-listener"
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


resource "cloudflare_record" "cf_api_subdomain_a_record" {
  zone_id         = var.cloudflare_zone_id
  name            = "${var.api_subdomain}.${var.base_domain}"
  value           = azurerm_public_ip.gw_ip.ip_address
  type            = "A"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "cf_portal_subdomain_a_record" {
  zone_id         = var.cloudflare_zone_id
  name            = "${var.portal_subdomain}.${var.base_domain}"
  value           = azurerm_public_ip.gw_ip.ip_address
  type            = "A"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "cf_domain_a_record" {
  zone_id         = var.cloudflare_zone_id
  name            = var.base_domain
  value           = azurerm_public_ip.gw_ip.ip_address
  type            = "A"
  proxied         = true
  allow_overwrite = true
}