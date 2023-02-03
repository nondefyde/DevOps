output "client_id" {
  value = data.azurerm_client_config.current.client_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "virtual_network_name" {
  value = module.gw_dep.virtual_network_name
}

output "resource_group_name" {
  value = module.gw_dep.gw_resource_group_name
}