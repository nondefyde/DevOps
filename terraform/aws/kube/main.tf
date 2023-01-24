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
  subnet_ids      = concat(module.vpc.public_subnet, module.vpc.private_subnet)
  vpc_id          = module.vpc.vpc_id
  cluster_name    = local.eks_cluster_name
  node_group_name = local.eks_node_group_name
  ssh_public_key  = var.ssh_public_key
}

resource "aws_ecr_repository" "app_registry" {
  name = var.app_project_prefix
  image_scanning_configuration {
    scan_on_push = false
  }
  force_delete = true
}