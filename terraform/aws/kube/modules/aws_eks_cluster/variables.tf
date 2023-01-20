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