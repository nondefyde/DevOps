variable "project" {
  type        = string
  description = "The project name"
}

variable "prefix" {
  type        = string
  description = "The prefix for the project"
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

variable "prevent_resource_deletion" {
  type = bool
  default = false
}