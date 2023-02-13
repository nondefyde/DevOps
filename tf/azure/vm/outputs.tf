output "vm_count" {
  value = var.vm_count
}

output "private_ip_address" {
  value = module.az_vm.*.private_ip_address
}
