output "vm_names" {
  value = azurerm_linux_virtual_machine.vm.*.name
}

output "private_ip_address" {
  value = azurerm_network_interface.vm_network_interface.*.private_ip_address
}