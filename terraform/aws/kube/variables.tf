variable "app_project_prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "destroy" {
  type = bool
  default = false
}

variable "aws_region" {
  type = string
  default = "AWS region"
}

variable "aws_key_id" {
  type = string
  default = "Aws access key id"
}

variable "aws_key_secret" {
  type = string
  default = "Aws access key secret"
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Subnet array"
}

variable "private_subnets" {
  type = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  description = "Subnet array"
}

variable "ssh_public_key" {
  type = string
}

variable "sa_namespace" {
  type = string
  default = "kube-system"
}

variable "sa_name" {
  type = string
  default = "aws-load-balancer-controller"
}