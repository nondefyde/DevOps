variable "prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "client_id" {
  type        = string
  description = "Azure Resource Manager Client ID"
  default     = "none"
}

variable "subscription_id" {
  type        = string
  description = "Azure Resource Manager Subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure Resource Manager Tenant ID"
}

variable "cloud_init_file" {
  type        = string
  description = "The File initialization file path"
}

variable "disk_size" {
  type        = string
  default     = "Standard_F2"
  description = "Disk size/type"
}

variable "location" {
  type        = string
  description = "Server location"
}

variable "client_secret" {
  type = string
  default = "Client secreet"
}

variable "admin_username" {
  type = string
  description = "Admin user name"
}

variable "admin_password" {
  type = string
  default = "Admin password"
}

variable "environment" {
  type = string
  description = "Development environment"
}

variable "dns_domain" {
  type = string
  description = "DNS domain"
}