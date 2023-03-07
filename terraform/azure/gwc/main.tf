data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_application_gateway" "gw_network" {
  name                = "${var.prefix}-app-gateway"
  resource_group_name = data.azurerm_resource_group.rg.name
}


data "azurerm_network_interface" "net_interface" {
  count               = var.vm_count
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "${var.prefix}-${var.name}-net-${count.index}"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_pool_name = "${var.name}-pool"
  backend_pool      = [for pool in data.azurerm_application_gateway.gw_network.backend_address_pool : pool if pool.name == local.backend_pool_name][0]
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
  count                   = length(data.azurerm_network_interface.net_interface)
  ip_configuration_name   = "${var.prefix}-${var.name}-internal-${count.index}"
  network_interface_id    = data.azurerm_network_interface.net_interface[count.index].id
  backend_address_pool_id = local.backend_pool.id
}