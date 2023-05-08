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
  source  = "terraform-iaac/nginx-controller/helm"
  atomic = true
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
    module.elb
  ]
}

#resource "kubernetes_manifest" "nginx" {
#  manifest = file("./yamls/nginx.yaml")
#}
#
#resource "kubernetes_service_account" "nginx-ingress" {
#  metadata {
#    name      = "nginx-ingress"
#    namespace = "kube-system"
#  }
#}
#
#resource "helm_release" "nginx-ingress" {
#  name       = "nginx-ingress"
#  namespace  = "kube-system"
#  repository = "https://kubernetes-charts.storage.googleapis.com/"
#  chart      = "nginx-ingress"
#  version    = "3.36.0"
#
#  set {
#    name  = "controller.service.type"
#    value = "LoadBalancer"
#  }
#
#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
#    value = "true"
#  }
#
#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
#    value = "http"
#  }
#
#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
#    value = "https"
#  }
#
#  set {
#    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
#    value = "arn:aws:acm:us-west-2:123456789012:certificate/abcde12345-6789-0123-4567-89abcdef0123"
#  }
#
#  set {
#    name  = "controller.publishService.enabled"
#    value = "false"
#  }
#
#  set {
#    name  = "controller.replicaCount"
#    value = "2"
#  }
#
#  set {
#    name  = "defaultBackend.enabled"
#    value = "false"
#  }
#
#  set {
#    name  = "rbac.create"
#    value = "true"
#  }
#
#  set {
#    name  = "rbac.serviceAccountName"
#    value = kubernetes_service_account.nginx-ingress.metadata.0.name
#  }
#}
#
#
#module "nginx-controller" {
#  source         = "terraform-iaac/nginx-controller/helm"
##  atomic = true
##    wait         = false
#  additional_set = [
#    {
#      name  = "region"
#      value = var.aws_region
#      type  = "string"
#    },
#    {
#      name  = "vpcId"
#      value = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
#      type  = "string"
#    },
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
#    {
#      name  = "clusterName"
#      value = local.eks_cluster_name
#      type  = "string"
#    },
#    {
#      name  = "controller.serviceAccount.create"
#      value = "false"
#      type  = "string"
#    },
#    {
#      name  = "controller.serviceAccountName"
#      value = "aws-load-balancer-controller"
#      type  = "string"
#    }
#  ]
#
#  depends_on = [
#    module.elb
#  ]
#}