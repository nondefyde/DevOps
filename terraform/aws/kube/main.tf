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

module "elb" {
  source       = "./modules/elb"
  project      = var.app_project_prefix
  vpc_id       = module.vpc.vpc_id
  cluster_name = local.eks_cluster_name
  issuer       = module.eks.issuer
  account_id   = data.aws_caller_identity.current.account_id
  aws_region   = var.aws_region
  depends_on   = [
    module.eks
  ]
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

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"
  atomic = true
  version = "2.2.0"
  additional_set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
      type  = "string"
    }
  ]

  depends_on = [
    module.elb,
    aws_ecr_repository.app_registry
  ]
}