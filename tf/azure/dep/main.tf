data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_network_interface" "vm_interface" {
  count               = var.vm_count
  name                = "${var.prefix}-${var.vm_name}-net-${count.index}"
  resource_group_name = "existing-group"
}

data "azurerm_linux_virtual_machine" "vms" {
  count               = var.vm_count
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_virtual_machine_extension" "deployment" {
  count               = var.vm_count
  name                 = "${var.prefix}-deployment"
  virtual_machine_id  = element(data.azurerm_linux_virtual_machine.vms.*.id, count.index)
  publisher           = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/dep/scripts/prep.sh", "https://raw.githubusercontent.com/nondefyde/DevOps/main/tf/azure/dep/scripts/deploy.sh"],
        "commandToExecute": "az login --service-principal --username ${var.client_id} --password ${var.client_secret} --tenant ${var.tenant_id}; chmod +x prep.sh; ./prep.sh ${var.prefix} ${var.image} ${var.app_secret}"
    }
SETTINGS
}