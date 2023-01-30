variable "prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "vpn_id" {
  type = string
}

variable "service" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_username" {
  type = string
  description = "Admin user name"
}

variable "admin_password" {
  type = string
  default = "Admin password"
}