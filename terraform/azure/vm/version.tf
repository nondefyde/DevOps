terraform {
  backend "azurerm" {}
  required_version = ">=0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}
