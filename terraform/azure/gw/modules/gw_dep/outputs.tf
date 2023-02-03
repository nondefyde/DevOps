output "gw_resource_group_name" {
  value = module.rg.resource_group_name
}

output "az_location_short" {
  value = module.azure_region.location_short
}

output "az_location" {
  value = module.azure_region.location
}

output "virtual_network_name" {
  value = module.azure_virtual_network.virtual_network_name
}

output "log_analytics_workspace_id" {
  value = module.run_common.log_analytics_workspace_id,
}

output "logs_storage_account_id" {
  value = module.run_common.logs_storage_account_id,
}