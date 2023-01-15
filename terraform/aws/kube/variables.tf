variable "app_project_prefix" {
  type        = string
  description = "The prefix for deployment"
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

///////////////// Deployment Variables /////////////////////////

variable "namespace" {
  type = string
  description = "The deployment namespace"
}

variable "app_name" {
  type        = string
  description = "Deployment project name"
}

variable "image_name" {
  type        = string
  description = "Deployment image name"
}

variable "image_tag" {
  type        = string
  description = "Deployment image tag"
}

variable "app_port" {
  type        = number
  description = "Deployment container port"
}
variable "ingress_host" {
  type        = string
  description = "The ingress host address"
}