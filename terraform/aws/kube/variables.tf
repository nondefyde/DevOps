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