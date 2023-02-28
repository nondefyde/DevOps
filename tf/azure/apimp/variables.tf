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

variable "name" {
  type = string
  default = "test"
}

variable "suffix" {
  type = string
  default = "tst"
}

variable "port" {
  type = number
  default = 8000
}

variable "protocols" {
  type = list(string)
  default = ["http"]
}

variable "display_name" {
  type = string
  default = "Test API"
}

variable "revision" {
  type = string
  default = "1"
}

variable "endpoints" {
  type = string
  default = "/*"
}
variable "methods" {
  type = list(string)
  default = [
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE"
  ]
}

variable "header" {
  type = string
  default = "x-api-key"
}

variable "apim_domain" {
  type = string
}

variable "gw_subdomain" {
  type = string
  default = "gw"
}
