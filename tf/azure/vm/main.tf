data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnets" {
  name                 = data.azurerm_virtual_network.vnet.subnets[count.index]
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  count                = length(data.azurerm_virtual_network.vnet.subnets)
}

module "az_vm" {
  source = "./modules/az_vm"

  name            = var.name
  vm_count        = var.vm_count
  group           = data.azurerm_resource_group.rg.name
  prefix          = var.prefix
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
  client_id       = var.client_id

  location  = data.azurerm_resource_group.rg.location
  subnet_id = data.azurerm_subnet.subnets[0].id

  cloud_init_file = var.init_file
  admin_username  = var.admin_username
  admin_password  = var.admin_password

  environment = var.environment
}

resource "null_resource" "example" {
  count = var.vm_count
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = element(module.az_vm.*.private_ip_address, count.index)
      user     = var.admin_username
      password = var.admin_password
    }

    inline = [
      "chmod +x ${var.init_file}",
      "${var.init_file} ${var.admin_username}"
    ]
  }

  depends_on = [module.az_vm]
}