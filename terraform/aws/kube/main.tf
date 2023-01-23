locals {
  eks_cluster_name = "${var.app_project_prefix}-cluster"
  eks_node_group_name = "${var.app_project_prefix}-node-group"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_public_key
}

module "vpc" {
  source                  = "./modules/vpc"
  tags                    = var.app_project_prefix
  instance_tenancy        = "default"
  vpc_cidr                = "10.0.0.0/16"
  access_ip               = "0.0.0.0/0"
  public_sn_count         = 2
  public_cidrs            = var.public_subnets
  map_public_ip_on_launch = true
  rt_route_cidr_block     = "0.0.0.0/0"
}

module "eks" {
  source                  = "./modules/eks"
  project                  = var.app_project_prefix
  aws_public_subnet       = module.vpc.aws_public_subnet
  vpc_id                  = module.vpc.vpc_id
  cluster_name            = local.eks_cluster_name
  endpoint_public_access  = true
  endpoint_private_access = false
  public_access_cidrs     = ["0.0.0.0/0"]
  node_group_name         = local.eks_node_group_name
  scaling_desired_size    = 2
  scaling_max_size        = 4
  scaling_min_size        = 1
  instance_types          = ["t3.medium"]
  key_pair                = aws_key_pair.deployer.key_name
}

resource "aws_ecr_repository" "app_registry" {
  name = var.app_project_prefix
  image_scanning_configuration {
    scan_on_push = false
  }
  force_delete = true
}
