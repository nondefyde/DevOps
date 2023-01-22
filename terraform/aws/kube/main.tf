locals {
  eks_cluster_name = "${var.app_project_prefix}-cluster"
}

module "eks_cluster" {
  source = "./modules/eks_cluster"

  prefix           = var.app_project_prefix
  eks_cluster_name = "${var.app_project_prefix}-cluster"
}

#
#module "load_balancer_controller" {
#  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"
#
#  enabled = true
#
#  cluster_identity_oidc_issuer     = module.eks_cluster.cluster_oidc_issuer_url
#  cluster_identity_oidc_issuer_arn = module.eks_cluster.oidc_provider_arn
#  cluster_name                     = module.eks_cluster.cluster_id
#
#  depends_on = [module.eks]
#}
#
#resource "aws_ecr_repository" "app_registry" {
#  name = var.app_project_prefix
#  image_scanning_configuration {
#    scan_on_push = false
#  }
#  force_delete = true
#}