variable "project" {
  type        = string
  description = "The prefix for deployment"
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "sa_namespace" {
  type = string
  default = "kube-system"
}

variable "sa_name" {
  type = string
  default = "nginx-controller"
}

variable "issuer" {
  type = string
}

variable "account_id" {
  type = string
}

variable "vpc_id" {
  type = string
}