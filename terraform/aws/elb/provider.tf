
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

data "aws_eks_cluster" "eks" {
  name = local.eks_cluster_name
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_key_id
  secret_key = var.aws_key_secret
}