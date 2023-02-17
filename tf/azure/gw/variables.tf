variable "prefix" {
  type        = string
  description = "The prefix for the resource group"
}

variable "group" {
  type        = string
  description = "The name of the vm"
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

variable "frontend_address_prefix" {
  type = string
  default = "10.0.3.0/24"
}

variable "backend_address_prefix" {
  type = string
  default = "10.0.4.0/24"
}

variable "vm_labels" {
  type = string
  default = "quest"
}