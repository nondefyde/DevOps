variable "prefix" {
  type        = string
  description = "The prefix for the resource group"
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

variable "group" {
  type = string
}

variable "cert_password" {
  type = string
  default = "password"
}

variable "cert_container_name" {
  type = string
  default = "cert"
}

variable "cert_name" {
  type = string
}

variable "devops_sa" {
  type = string
}

variable "devops_sa_rg" {
  type = string
}