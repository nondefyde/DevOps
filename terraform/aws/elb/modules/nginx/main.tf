module "nginx-controller" {
  source         = "terraform-iaac/nginx-controller/helm"
#  atomic         = true
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
    },
    {
      name  = "controller.serviceAccount.create"
      value = "false"
      type  = "string"
    },
    {
      name  = "controller.serviceAccount.name"
      value = "nginx-controller"
      type  = "string"
    },
    {
      name  = "controller.serviceAccount.namespace"
      value = "kube-system"
      type  = "string"
    }
  ]

  depends_on = [
    kubernetes_service_account.nginx-controller
  ]
}