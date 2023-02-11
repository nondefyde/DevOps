data "azurerm_resource_group" "rg" {
  name = var.group
}

data "azurerm_api_management" "apim" {
  name                = "${var.prefix}-api"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_api_management_api" "apimp" {
  name                  = "${var.prefix}-${var.name}-http-api"
  resource_group_name   = data.azurerm_resource_group.rg.name
  api_management_name   = data.azurerm_api_management.apim.name
  revision              = var.revision
  display_name          = var.display_name
  path                  = var.suffix
  protocols             = var.protocols
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "apimp_operations" {
  count               = length(var.methods)
  operation_id        = "${var.prefix}-${var.name}-operation-${count.index}"
  api_name            = azurerm_api_management_api.apimp.name
  api_management_name = data.azurerm_api_management.apim.name
  resource_group_name = data.azurerm_resource_group.rg.name
  display_name        = "${var.methods[count.index]} Resource"
  method              = var.methods[count.index]
  url_template        = var.endpoints

  request {
    header {
      name     = var.header
      type     = "string"
      required = true
    }
  }
}