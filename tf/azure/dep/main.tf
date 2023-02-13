data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_network_interface" "example" {
  count               = var.vm_count
  name                = "${var.prefix}-${var.vm_name}-net-${count.index}"
  resource_group_name = "existing-group"
}

data "azurerm_linux_virtual_machine" "example" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "null_resource" "example" {
  count = var.vm_count
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.admin_username
      host     = element(data.azurerm_network_interface.example.*.private_ip_address, count.index)
      password = var.admin_password
    }

    inline = [
      "az login --service-principal --username ${var.client_id} --password ${var.client_secret} --tenant ${var.tenant_id}"
      "chmod +x ./deploy.sh",
      "./deploy.sh ${var.project} ${var.image} ${var.app_secret}"
    ]
  }
}