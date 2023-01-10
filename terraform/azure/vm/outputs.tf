output "public_ip_address" {
  value = module.az_create_vm.public_ip_address
}

output "client_id" {
  value = data.azurerm_client_config.current.client_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "tls_private_key" {
  value     = module.az_create_vm.tls_private_key
  sensitive = true
}

output "admin_username" {
  value = module.az_create_vm.admin_username
}

output "init_file" {
  value = var.init_file
}

output "admin_ssh_key" {
  value = module.az_create_vm.admin_ssh_key
  sensitive = true
}
