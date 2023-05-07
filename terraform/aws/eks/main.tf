locals {
  eks_cluster_name = "${var.app_project_prefix}-cluster"
  eks_node_group_name = "${var.app_project_prefix}-node-group"
}

module "vpc" {
  source       = "./modules/vpc"
  cluster_name = local.eks_cluster_name
  project      = var.app_project_prefix
}

module "eks" {
  source          = "./modules/eks"
  project         = var.app_project_prefix
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_name    = local.eks_cluster_name
  node_group_name = local.eks_node_group_name
  instance_types  = [var.instance_type]
}


resource "aws_ecr_repository" "app_registry" {
  name = var.app_project_prefix
  image_scanning_configuration {
    scan_on_push = false
  }
  force_delete = true
  depends_on   = [
    module.eks
  ]
}