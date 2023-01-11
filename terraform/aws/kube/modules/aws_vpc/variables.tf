variable "prefix" {
  type        = string
  description = "The prefix for deployment"
  default     = "stmx"
}

variable "vpc_name" {
  type = string
  default = "EKS vpc name"
}

variable "tag_cluster_name" {
  type = string
  default = "EKS cluster name"
}

variable "private_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Subnet array"
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  description = "Subnet array"
}