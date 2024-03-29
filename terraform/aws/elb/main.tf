locals {
  eks_cluster_name = "${var.app_project_prefix}-cluster"
  issuer = trimprefix (data.aws_eks_cluster.eks.identity.0.oidc.0.issuer, "https://")
}

module "alb" {
  source       = "./modules/alb"
  project      = var.app_project_prefix
  vpc_id       = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  cluster_name = data.aws_eks_cluster.eks.name
  issuer       = local.issuer
  account_id   = data.aws_caller_identity.current.account_id
  aws_region   = var.aws_region
}

module "nginx" {
  source       = "./modules/nginx"
  project      = var.app_project_prefix
  vpc_id       = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  cluster_name = data.aws_eks_cluster.eks.name
  issuer       = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
  account_id   = data.aws_caller_identity.current.account_id
  aws_region   = var.aws_region
  depends_on = [
    module.alb
  ]
}
#
#module "nginx-controller" {
#  source         = "terraform-iaac/nginx-controller/helm"
#  #  atomic         = true
#  additional_set = [
#    {
#      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
#      value = "nlb"
#      type  = "string"
#    },
#    {
#      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
#      value = "true"
#      type  = "string"
#    },
#  ]
#
#  depends_on = [
#    module.alb
#  ]
#}