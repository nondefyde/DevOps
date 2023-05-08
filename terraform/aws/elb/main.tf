locals {
  eks_cluster_name = "${var.app_project_prefix}-cluster"
}

module "elb" {
  source       = "./modules/elb"
  project      = var.app_project_prefix
  vpc_id       = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  cluster_name = data.aws_eks_cluster.eks.name
  issuer       = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
  account_id   = data.aws_caller_identity.current.account_id
  aws_region   = var.aws_region
}
