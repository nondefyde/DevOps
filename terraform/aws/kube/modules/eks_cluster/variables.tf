variable "prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "eks_nodegroup_one_name" {
  type        = string
  description = "Node group name"
}

variable "eks_cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "vpc_subnet_ids" {
  description = "VPC Subnet IDs for cluster nodes"
  type        = set(string)
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

variable "map_roles" {
  type = list(string)
  description = "List of role maps to add to the aws-auth configmap"
  default = []
}

variable "map_users" {
  type = list(string)
  description = "List of users maps to add to the aws-auth configmap"
  default = []
}

variable "map_accounts" {
  type = list(string)
  description = "List of account maps to add to the aws-auth configmap"
  default = []
}