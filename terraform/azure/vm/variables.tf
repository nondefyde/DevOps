variable "app_project_prefix" {
  type        = string
  description = "The prefix for deployment"
  default     = "stmx"
}

variable "cloudflare_api_token" {
  type = string
  description = "Cloudflare api token"
}

variable "cloudflare_zone_id" {
  type = string
  description = "Cloudflare zone id"
}

variable "location" {
  type        = string
  default     = "Central US"
  description = "Server location"
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


variable "admin_username" {
  type        = string
  description = "Admin username"
  default     = "adminuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password"
  default = "password"
}

variable "init_file" {
  type        = string
  description = "The entry file when server is setup"
  default     = "./vm.sh"
}

variable "environment" {
  type = string
  default = "staging"
  description = "The development environment"
}

variable "dns_domain" {
  type = string
  default = "dev.stemuli.net"
  description = "The dns domain"
}

variable "service" {
  type = string
  default = "dev"
}
