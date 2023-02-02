resource "azurerm_resource_group" "vm_group" {
  name     = "${var.app_project_prefix}-group"
  location = var.location
}