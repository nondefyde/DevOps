#######modules/eks/variables.tf

variable "project" {type = string}

variable "subnet_ids" {
  type = list(string)
}

variable "ssh_public_key" {
  type = string
}

variable "vpc_id" {}

variable "cluster_name" {}

variable "endpoint_private_access" {
  type = bool
  default = false
}

variable "endpoint_public_access" {
  type = bool
  default = true
}

variable "public_access_cidrs" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "node_group_name" {
  type = string
}

variable "scaling_desired_size" {
  type = number
  default = 2
}

variable "scaling_max_size" {
  type = number
  default = 4
}

variable "scaling_min_size" {
  type = number
  default = 1
}

variable "instance_types" {
  type = list(string)
  default = ["t3.large"]
}
