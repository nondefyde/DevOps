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

variable "cloudflare_api_token" {
  type = string
  description = "Cloudflare api token"
}

variable "cloudflare_zone_id" {
  type = string
  description = "Cloudflare zone id"
}


variable "group" {
  type = string
}

variable "service_domain" {
  type = string
}