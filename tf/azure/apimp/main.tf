data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_api_management" "apim" {
  name                = "search-api"
  resource_group_name = "search-service"
}

resource "azurerm_api_management_api" "example" {
  name                = "example-api"
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = data.azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Example API"
  path                = "example"
  protocols           = ["https"]
}