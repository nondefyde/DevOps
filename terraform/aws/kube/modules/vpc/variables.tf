####### modules/vpc/variables.tf
variable "project" {
  type = string
}
variable "cluster_name" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Public Subnet array"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
  description = "Private Subnet array"
}
