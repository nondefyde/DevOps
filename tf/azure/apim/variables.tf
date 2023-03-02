variable "prefix" {
  type        = string
  description = "The prefix for the resource group"
}

variable "group" {
  type = string
}

variable "subscription_id" {
  type        = string
  description = "Azure Resource Manager Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Resource Manager Tenant ID"
}

variable "client_id" {
  type        = string
  description = "Client ID"
}

variable "client_secret" {
  type        = string
  description = "Client ID"
}

variable "publisher_name" {
  type = string
}

variable "publisher_email" {
  type = string
}

variable "environment" {
  type = string
  default = "development"
}

variable "sku" {
  type = string
  default = "Developer"
}

variable "capacity" {
  type = number
  default = 1
}

variable "apim_domain" {
  type = string
}

variable "gateway_subdomain" {
  type = string
  default = "api"
}

variable "portal_subdomain" {
  type = string
  default = "portal"
}

variable "vault_name" {
  type = string
}

variable "vault_rg" {
  type = string
}

variable "cert_name" {
  type = string
}