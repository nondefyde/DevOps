variable "prefix" {
  type        = string
  description = "The prefix for the resource group"
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

variable "group" {
  type = string
}

variable "apim_domain" {
  type = string
}

variable "cert" {
  type = string
}

variable "cert_key" {
  type = string
}