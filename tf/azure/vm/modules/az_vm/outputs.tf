output "vm_names" {
  value = azurerm_linux_virtual_machine.vm.*.name
}
