variable "app_project_prefix" {
  type        = string
  description = "The prefix for deployment"
  default     = "stmx"
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

variable "private_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Subnet array"
}