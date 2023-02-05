resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-group"
  location = var.location
}