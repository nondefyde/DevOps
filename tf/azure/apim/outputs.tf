output "apim_id" {
  value = azurerm_api_management.apim.id
}

output "management_api_url" {
  value = azurerm_api_management.apim.management_api_url
}

output "gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}

output "portal_url" {
  value = azurerm_api_management.apim.portal_url
}

output "developer_portal_url" {
  value = azurerm_api_management.apim.developer_portal_url
}

output "private_ip_addresses" {
  value = join(",", azurerm_api_management.apim.private_ip_addresses)
}