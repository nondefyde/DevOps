variable "app_project_prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "instance_type" {
  type = string
  default = "t3.large"
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

variable "sa_namespace" {
  type = string
  default = "kube-system"
}

variable "sa_name" {
  type = string
  default = "aws-load-balancer-controller"
}