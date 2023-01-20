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

variable "repository" {
  type = string
  description = "The default repository"
  default = "localdev",
}