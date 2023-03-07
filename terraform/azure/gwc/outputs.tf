output "gw_name" {
  value = data.azurerm_application_gateway.gw_network.name
}

output "backend_pool_name" {
  value = local.backend_pool.name
}

output "backend_pool_id" {
  value = local.backend_pool.id
}