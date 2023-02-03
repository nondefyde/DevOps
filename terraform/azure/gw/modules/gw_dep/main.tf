module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "6.1.0"

  azure_region = var.azr_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "6.1.0"

  location    = module.azure_region.location
  client_name = var.client
  environment = var.environment
  stack       = var.stack
}

module "run_common" {
  source  = "claranet/run-common/azurerm"
  version = "7.3.0"

  client_name         = var.client
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  environment         = var.environment
  stack               = var.stack
  resource_group_name = module.rg.resource_group_name

  tenant_id = var.tenant_id

  monitoring_function_splunk_token = null
}

module "azure_virtual_network" {
  source  = "claranet/vnet/azurerm"
  version = "5.2.0"

  environment    = var.environment
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  vnet_cidr = ["10.10.0.0/16"]
}