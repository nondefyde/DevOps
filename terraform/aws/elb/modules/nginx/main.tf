module "nginx-controller" {
  source         = "terraform-iaac/nginx-controller/helm"
  atomic         = true
  additional_set = [
    {
      name  = "region"
      value = var.aws_region
      type  = "string"
    },
    {
      name  = "vpcId"
      value = var.vpc_id
      type  = "string"
    },
    {
      name  = "clusterName"
      value = var.cluster_name
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
      name  = "controller.serviceAccount.name"
      value = "aws-load-balancer-controller"
      type  = "string"
    }
  ]

  depends_on = [
    kubernetes_service_account.service_account
  ]
}