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

variable "environment" {
  type = string
  default = "development"
}

variable "admin_username" {
  type = string
  default = "adminuser"
}

variable "admin_password" {
  type = string
}

variable "init_file" {
  type        = string
  description = "The entry file when server is setup"
  default     = "./vm.sh"
}

variable "vm_count" {
  type = string
  default = 1
}

variable "name" {
  type = string
}