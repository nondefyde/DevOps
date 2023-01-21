provider "aws" {
  region     = var.aws_region
  access_key = var.aws_key_id
  secret_key = var.aws_key_secret
}

data "aws_caller_identity" "current" {}

locals {
  eks_vpc_name           = "${var.app_project_prefix}-vpc"
  eks_cluster_name       = "${var.app_project_prefix}-cluster"
  eks_nodegroup_one_name = "${var.app_project_prefix}-nodegroup"
}

module "module_vpc" {
  source = "./modules/aws_vpc"

  vpc_name = local.eks_vpc_name
  tag_cluster_name = local.eks_cluster_name
}

module "aws_eks_cluster" {
  source = "./modules/aws_eks_cluster"

  prefix                 = var.app_project_prefix
  eks_cluster_name       = local.eks_cluster_name
  eks_nodegroup_one_name = local.eks_nodegroup_one_name
  vpc_subnet_ids         = module.module_vpc.vpc_private_subnet_ids
}


resource "aws_ecr_repository" "app_registry" {
  name = var.app_project_prefix
  image_scanning_configuration {
    scan_on_push = false
  }
  force_delete = true
}