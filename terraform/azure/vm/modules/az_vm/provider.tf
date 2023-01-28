terraform {
  required_version = ">=1.0.8"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.41.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}