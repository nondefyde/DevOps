variable "prefix" {
  type        = string
  description = "The prefix for the resource group"
}

variable "group" {
  type        = string
  description = "The name of the vm"
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
  description = "Client Secret"
}

variable "api_suffixes" {
  type    = string
  default = "quest:qst:8000:200"
}

variable "sku_name" {
  type = string
  default = "Standard_v2"
}

variable "sku_tier" {
  type = string
  default = "Standard_v2"
}

variable "sku_capacity" {
  type = number
  default = 2
}

variable "private_ip" {
  type = string
  default = "10.0.3.10"
}

variable "apim_domain" {
  type = string
}

variable "cert_password" {
  type = string
  default = "password"
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