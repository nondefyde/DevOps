variable "prefix" {
  type        = string
  description = "The prefix for the resource group"
}

variable "location" {
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

variable "public_ip" {
  type        = string
  description = "Azure Resource Manager Subscription ID"
}

variable "public_ip_id" {
  type = string
}

variable "public_ip_dns_name" {
  type        = string
  description = "public dns for cname"
}

variable "dns_domain" {
  type = string
  description = "DNS domain"
}

variable "cloudflare_zone_id" {
  type = string
  description = "Cloudflare zone id"
}

variable "service" {
  type = string
}

variable "api_gateway" {
  type = string
  default = "devcloudapps-api.azure-api.net"
}