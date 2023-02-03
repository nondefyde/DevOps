variable "app_project_prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "app_group" {
  type        = string
  description = "The prefix for deployment"
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

variable "service" {
  type = string
}

variable "admin_username" {
  type        = string
  description = "Admin username"
  default     = "adminuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password"
  default = "Stemuli_1@###"
}

