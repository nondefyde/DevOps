variable "prefix" {
  type        = string
  description = "The prefix for deployment"
}

variable "eks_cluster_name" {
  type        = string
  description = "Cluster name"
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


variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = [
    "777777777777",
    "888888888888",
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]
}

variable "roles" {
  description = "Array of RBAC roles to secrets in a specific namespace that the lb controller needs access to"
  type = list(object({
    name          = string
    namespace     = string
    resourcenames = list(string)
  }))

  default = [
    {
      name          = "role-name"
      namespace     = "default"
      resourcenames = ["secret1", "secret2"]
    }
  ]
}