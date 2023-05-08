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


module "nginx-controller" {
  source         = "terraform-iaac/nginx-controller/helm"
#  atomic = true
#    wait         = false
  additional_set = [
    {
      name  = "region"
      value = var.aws_region
      type  = "string"
    },
    {
      name  = "vpcId"
      value = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
      type  = "string"
    },
    {
      name  = "clusterName"
      value = local.eks_cluster_name
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
      type  = "string"
    },
    {
      name  = "controller.serviceAccount.create"
      value = "false"
      type  = "string"
    },
    {
      name  = "controller.serviceAccountName"
      value = "aws-load-balancer-controller"
      type  = "string"
    }
  ]

  depends_on = [
    module.elb
  ]
}
