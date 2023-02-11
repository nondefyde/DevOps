resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-group"
  location = var.location
}

resource "azurerm_container_registry" "vm_acr" {
  name                = "${var.prefix}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false

  georeplications {
    location = "East US 2"
  }
  depends_on = [azurerm_resource_group.rg]
}