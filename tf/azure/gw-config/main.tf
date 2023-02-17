data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_network_interface" "vm_network_interfaces" {
  count               = var.vm_count
  name                = "${var.prefix}-${var.name}-net-${count.index}"
  resource_group_name = data.azurerm_resource_group.rg.name

  filter {
    address_configuration {
      # Replace with the private IP address of the virtual machine
      name = "${var.prefix}-${var.name}-vm-${count.index + 1}"
    }
  }
}

data "azurerm_application_gateway" "gw_network" {
  name                = "existing-app-gateway"
  resource_group_name = "existing-resources"
}

resource "azurerm_network_interface_backend_address_pool_association" "backend_assoc" {
  count                   = var.vm_count
  network_interface_id    = element(data.azurerm_network_interface.vm_network_interfaces.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-${var.name}-ip-config-${count.index}"
  backend_address_pool_id = element(data.azurerm_application_gateway.gw_network.backend_address_pool.*.id, count.index)
}