output "public_ip_address" {
  value = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.vm_ssh.private_key_pem
  sensitive = true
}

output "admin_username" {
  value     = azurerm_linux_virtual_machine.virtual_machine.admin_username
}

output "admin_ssh_key" {
  value = azurerm_linux_virtual_machine.virtual_machine.admin_ssh_key
}