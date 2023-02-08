data "template_file" "vm_init" {
  template = file(var.cloud_init_file)
  vars     = {
    prefix               = var.prefix
    user                 = var.admin_username
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = "${var.prefix}-${var.name}-vm-${count.index}"
  location              = var.location
  availability_set_id   = azurerm_availability_set.vm_avset.id
  resource_group_name   = var.group
  network_interface_ids = [element(azurerm_network_interface.vm_network_interface.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

   delete_os_disk_on_termination = true

   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}${var.name}myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Optional data disks
  storage_data_disk {
    name              = "${var.prefix}_${var.name}_datadisk_new_${count.index}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "100"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.vm_managed_disk.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.vm_managed_disk.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.vm_managed_disk.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.name}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  custom_data = base64encode(data.template_file.vm_init.rendered)

  tags = {
    environment = var.environment
  }
}