data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "frontend" {
  name                 = "${var.prefix}-frontend-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.frontend_address_prefix]
}

resource "azurerm_subnet" "backend" {
  name                 = "${var.prefix}-backend-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [var.backend_address_prefix]
}

resource "azurerm_public_ip" "gw_ip" {
  name                = "${var.prefix}-gw-pip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  vm_names                           = toset(split(",", var.app_names))
  names                              = split(",", var.app_names)
  app_suffixes                       = toset(split(",", var.app_suffixes))
  frontend_port_name                 = "${var.prefix}-gw-feport"
  frontend_ip_configuration_name     = "${var.prefix}-gw-feip"
  index_list                         = range(length(local.names))
  backend_address_pool_name_to_index = {for idx, name in local.names : name => idx}
}

resource "azurerm_application_gateway" "gw_network" {
  name                = "${var.prefix}-app-gateway"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.prefix}-gw-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.gw_ip.id
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
    protocol              = "Http"
    request_timeout       = 60
  }

  dynamic "backend_address_pool" {
    for_each = local.vm_names
    content {
      name = "${var.prefix}-${backend_address_pool.value}-pool"
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
  }

  url_path_map {
    name                               = "${var.prefix}-url-path-map"
    default_backend_address_pool_name  = "${var.prefix}-sink-pool"
    default_backend_http_settings_name = "${var.prefix}-http-setting"

    dynamic "path_rule" {
      for_each = local.app_suffixes
      content {
        name                       = "${path_rule.value}-url-path-rule"
        backend_address_pool_name  = "${var.prefix}-${path_rule.value}-pool"
        backend_http_settings_name = "${var.prefix}-http-setting"
        paths                      = [
          "/${path_rule.value}",
        ]
      }
    }
  }
}