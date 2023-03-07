terraform {
  backend "azurerm" {}
  required_version = ">=1.0.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.44.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.30.0"
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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}