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
  vm_names                       = toset(split(",", var.vm_labels))
  frontend_port_name             = "${data.azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${data.azurerm_virtual_network.vnet.name}-feip"
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

  dynamic "http_listener" {
    for_each = local.vm_names
    content {
      name                           = "${http_listener.key}-http-listener"
      frontend_ip_configuration_name = local.frontend_ip_configuration_name
      frontend_port_name             = local.frontend_port_name
      protocol                       = "Http"
    }
  }

  dynamic "backend_address_pool" {
    for_each = local.vm_names
    content {
      name = "${backend_address_pool.key}-pool"
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.vm_names
    content {
      name                  = "${backend_http_settings.key}-http-setting"
      cookie_based_affinity = "Disabled"
      port                  = 8000
      protocol              = "Http"
      request_timeout       = 60
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.vm_names
    content {
      name                       = "${request_routing_rule.key}-routing-tb"
      rule_type                  = "Basic"
      http_listener_name         = "${http_listener[request_routing_rule.key].name}"
      backend_address_pool_name  = "${backend_address_pool[request_routing_rule.key].name}"
      backend_http_settings_name = "${backend_http_settings[request_routing_rule.key].name}"
      url_path_map_name = "${request_routing_rule.key}-url-path"
    }
  }

  dynamic "url_path_map" {
    for_each = local.vm_names
    content {
      name                               = "${url_path_map.key}-url-path"
      default_backend_address_pool_name  = "${backend_address_pool[url_path_map.key].name}"
      backend_address_pool_name = "${backend_address_pool[url_path_map.key].name}"

      path_rule {
        name                        = "${url_path_map.key}-url-path-rule"
        redirect_configuration_name = "${url_path_map.key}-url-path"
        paths = [
          "/${url_path_map.key}",
        ]
      }
    }
  }
}