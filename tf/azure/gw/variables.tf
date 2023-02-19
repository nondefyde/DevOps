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
  default = "quest:qst"
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