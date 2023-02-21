variable "prefix" {
  type        = string
  description = "The prefix for the resource group"
}

variable "name" {
  type = string
}

variable "vm_count" {
  type = number
}

variable "location" {
  type = string
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

variable "address_prefix" {
  type = string
  default = "10.0.2.0/24"
}

variable "environment" {
  type = string
  default = "development"
}

variable "subnet_id" {
  type = string
}

variable "disk_size" {
  type        = string
  default     = "Standard_F2"
  description = "Disk size/type"
}

variable "admin_username" {
  type = string
  default = "adminuser"
}

variable "admin_password" {
  type = string
}

variable "cloud_init_file" {
  type        = string
  description = "The File initialization file path"
}

variable "apim_domain" {
  type = string
}