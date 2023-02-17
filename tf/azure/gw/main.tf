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
  vm_names                           = toset(split(",", var.vm_labels))
  names                              = split(",", var.vm_labels)
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
      name = "${backend_address_pool.value}-pool"
    }
  }

  backend_address_pool {
    name = "${var.prefix}-sink-pool"
  }

  request_routing_rule {
    name                       = "${var.prefix}-routing-tb"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-http-listener"
    backend_address_pool_name  = "${var.prefix}-sink-pool"
    backend_http_settings_name = "${var.prefix}-http-setting"
    #    url_path_map_name          = "${request_routing_rule.value}-url-path-map"
  }

  #  dynamic "url_path_map" {
  #    name                            = "${var.prefix}-url-path-map"
  #    default_backend_address_pool_id = backend_address_pool[local.vm_names[0]].id
  #    dynamic "path_rule" {
  #      for_each = local.vm_names
  #      content {
  #        name                    = "${url_path_map.value}-url-path-rule"
  #        backend_address_pool_id = backend_address_pool[url_path_map.value].id
  #        paths                   = [
  #          "/${url_path_map.value}",
  #        ]
  #      }
  #    }
  #  }
}

data "azurerm_network_interface" "net_interface" {
  count = length(local.names)

  resource_group_name = data.azurerm_resource_group.rg.name
  name               = "${var.prefix}-${element(split(":", local.names[count.index]), 0)}-net-${element(local.index_list, count.index)}"
}

#data "azurerm_network_interface" "net_interface" {
#  for_each = {for name in local.names : name => name if can(regex("^[a-zA-Z]+", name))}
#
#  resource_group_name = data.azurerm_resource_group.rg.name
#
#  name = "${var.prefix}-${each.value}-net-${element(local.index_list, count.index)}"
#}

#data "azurerm_network_interface" "net_interface" {
#  count               = length(local.names)
#  resource_group_name = data.azurerm_resource_group.rg.name
#  dynamic "name" {
#    for_each = split(":", local.names[count.index])
#    content {
#      name = "${var.prefix}-${name.value}-net-${name.key}"
#    }
#  }
#}


#resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
#  count = length(local.names)
#
#  dynamic "ip_configuration_name" {
#    for_each = data.azurerm_network_interface.net_interface[count.index]
#    content {
#      ip_configuration_name = "${var.prefix}-nic-ipconfig-${ip_configuration_name.value.internal_dns_name_label}"
#    }
#  }
#
#  dynamic "backend_address_pool_id" {
#    for_each = local.vm_names
#    content {
#      backend_address_pool_id = azurerm_application_gateway.gw_network.backend_address_pool[backend_address_pool_name_to_index(local.names, backend_address_pool_id)].id
#    }
#  }
#
#  dynamic "network_interface_id" {
#    for_each = data.azurerm_network_interface.net_interface[count.index]
#    content {
#      network_interface_id = network_interface_id.value.id
#    }
#  }
#}