variable "app_project_prefix" {
  type        = string
  description = "The prefix for deployment"
  default     = "stmx"
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

variable "environment" {
  type = string
  default = "staging"
  description = "The development environment"
}

variable "service" {
  type = string
}
