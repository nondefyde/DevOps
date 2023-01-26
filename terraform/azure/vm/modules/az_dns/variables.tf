variable "prefix" {
  type        = string
  description = "The prefix for deployment"
}


variable "public_ip" {
  type        = string
  description = "Azure Resource Manager Subscription ID"
}

variable "dns_domain" {
  type = string
  description = "DNS domain"
}