resource "azurerm_resource_group" "vm_group" {
  name     = "${var.app_project_prefix}-group"
  location = var.location
}

module "az_vm" {
  source = "./modules/az_vm"

  prefix          = var.app_project_prefix
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
  client_id       = var.client_id
  location        = var.location
  cloud_init_file = var.init_file
  admin_username  = var.admin_username
  admin_password  = var.admin_password
  environment     = var.environment
  dns_domain      = var.dns_domain

  depends_on = [azurerm_resource_group.vm_group]
}

resource "azurerm_container_registry" "vm_acr" {
  name                = "${var.app_project_prefix}acr"
  resource_group_name = azurerm_resource_group.vm_group.name
  location            = azurerm_resource_group.vm_group.location
  sku                 = "Premium"
  admin_enabled       = false

  georeplications {
    location = "East US"
  }

  depends_on = [module.az_vm]
}

module "az_dns" {
  source = "./modules/az_dns"

  prefix             = var.app_project_prefix
  public_ip          = module.az_vm.public_ip_address
  public_ip_id       = module.az_vm.public_ip_id
  public_ip_dns_name = module.az_vm.public_dns_name
  dns_domain         = var.dns_domain
  cloudflare_zone_id = var.cloudflare_zone_id
  service            = var.service


  depends_on         = [azurerm_resource_group.vm_group]
}

