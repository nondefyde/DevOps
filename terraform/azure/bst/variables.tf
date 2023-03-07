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
  description = "Client Secret"
}

variable "address_prefix" {
  type    = string
  default = "10.0.7.0/24"
}

variable "shareable_link_enabled" {
  type    = bool
  default = true
}

variable "sku" {
  type    = string
  default = "Standard"
}