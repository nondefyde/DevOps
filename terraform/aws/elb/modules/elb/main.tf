resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service_account
  ]

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  wait_for_jobs = true
}

module "nginx-controller" {
  source         = "terraform-iaac/nginx-controller/helm"
  #  atomic = true
  #    wait         = false
  additional_set = [
    {
      name  = "clusterName"
      value = var.cluster_name
      type  = "string"
    },
    {
      name  = "region"
      value = var.aws_region
      type  = "string"
    },
    {
      name  = "vpcId"
      value =  var.vpc_id
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
    helm_release.lb
  ]
}