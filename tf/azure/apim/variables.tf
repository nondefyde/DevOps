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

variable "cloudflare_api_token" {
  type = string
  description = "Cloudflare api token"
}

variable "cloudflare_zone_id" {
  type = string
  description = "Cloudflare zone id"
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

variable "address_prefix" {
  type = string
  default = "10.0.5.0/24"
}