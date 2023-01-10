terraform {
  backend "azurerm" {}
  required_version = ">=0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "vm_group" {
  name     = "${var.app_project_prefix}-group"
  location = var.location
}

module "az_create_vm" {
  source = "./modules/az_create_vm"

  prefix          = var.app_project_prefix
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
  client_id       = var.client_id
  location        = var.location
  cloud_init_file = var.init_file
  admin_username  = var.admin_username
  admin_password  = var.admin_password
  environment  = var.environment
  dns_domain  = var.dns_domain

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

  depends_on = [azurerm_resource_group.vm_group]
}

