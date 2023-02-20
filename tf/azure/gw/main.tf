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
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.gw_ip.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.private_ip
  }

  http_listener {
    name                           = "${var.prefix}-http-listener"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  backend_http_settings {
    name                  = "${var.prefix}-http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 8000
    path                  = "/"
    protocol              = "Http"
    request_timeout       = 60
  }

  dynamic "backend_address_pool" {
    for_each = local.api_suffixes
    content {
      name = "${var.prefix}-${split(":", backend_address_pool.value)[0]}-pool"
    }
  }

  backend_address_pool {
    name = "${var.prefix}-sink-pool"
  }

  request_routing_rule {
    name                       = "${var.prefix}-routing-tb"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "${var.prefix}-http-listener"
    backend_address_pool_name  = "${var.prefix}-sink-pool"
    backend_http_settings_name = "${var.prefix}-http-setting"
    url_path_map_name          = "${var.prefix}-url-path-map"
    priority                   = 100
  }

  url_path_map {
    name                               = "${var.prefix}-url-path-map"
    default_backend_address_pool_name  = "${var.prefix}-sink-pool"
    default_backend_http_settings_name = "${var.prefix}-http-setting"

    dynamic "path_rule" {
      for_each = local.api_suffixes
      content {
        name                       = "${split(":", path_rule.value)[0]}-url-path-rule"
        backend_address_pool_name  = "${var.prefix}-${split(":", path_rule.value)[0]}-pool"
        backend_http_settings_name = "${var.prefix}-http-setting"
        paths                      = [
          "/${split(":", path_rule.value)[1]}/*",
        ]
      }
    }
  }
}