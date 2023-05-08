locals {
  eks_cluster_name = "${var.app_project_prefix}-cluster"
}

data "tls_certificate" "tls" {
  url = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

resource "null_resource" "update-kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}"
  }

  depends_on = [
    aws_iam_openid_connect_provider.oidc,
    aws_iam_policy.elb-policy
  ]
}

resource "null_resource" "associate_iam_oidc_provider" {
  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --region=${var.aws_region} --cluster=${var.cluster_name} --approve"
  }

  depends_on = [
    null_resource.update-kubeconfig,
    aws_iam_policy.elb-policy
  ]
}

module "elb" {
  source       = "./modules/elb"
  project      = var.app_project_prefix
  vpc_id       = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  cluster_name = data.aws_eks_cluster.eks.name
  issuer       = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
  account_id   = data.aws_caller_identity.current.account_id
  aws_region   = var.aws_region

  depends_on = [
    null_resource.associate_iam_oidc_provider
  ]
}

#
#module "nginx" {
#  source       = "./modules/nginx"
#  project      = var.app_project_prefix
#  vpc_id       = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
#  cluster_name = data.aws_eks_cluster.eks.name
#  issuer       = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
#  account_id   = data.aws_caller_identity.current.account_id
#  aws_region   = var.aws_region
#}