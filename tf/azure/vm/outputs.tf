output "virtual_network_name" {
  value = module.az_vm.vm_name
}

output "subnet_ids" {
  value = data.azurerm_subnet.subnets.*.id
}