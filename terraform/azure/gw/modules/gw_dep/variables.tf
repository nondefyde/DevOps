variable "client" {
  type        = string
  description = "The client name"
}

variable "environment" {
  type = string
  default = "staging"
  description = "The development environment"
}

variable "azr_region" {
  type = string
  default = "eu-west"
}

variable "stack" {
  type = string
  default = "Node JS"
}

variable "tenant_id" {
  type = string
}
