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

variable "vm_name" {
  type = string
}

variable "vm_count" {
  type = number
  default = 1
}

variable "admin_username" {
  type = string
  default = "adminuser"
}

variable "admin_password" {
  type = string
}

variable "image" {
  type = string
}

variable "app_secret" {
  type = string
}