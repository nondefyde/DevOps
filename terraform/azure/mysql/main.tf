terraform {
  backend "azurerm" {}
  required_version = ">=1.0.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.41.0"
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

module "az_mysql" {
  source = "./modules/az_mysql"
  prefix         = var.app_project_prefix
  location       = var.location
  admin_username = var.admin_username
  admin_password = var.admin_password
  service        = var.service
}