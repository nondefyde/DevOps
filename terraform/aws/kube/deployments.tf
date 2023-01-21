data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = module.aws_eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks_cluster.kubeconfig_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.namespace
  }
  depends_on = [module.aws_eks_cluster]
}

#--------------Ingress Controller----------------------
provider "helm" {
  kubernetes {
    host                   = module.aws_eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks_cluster.kubeconfig_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.1.0"

  providers = {
    kubernetes = "kubernetes.eks"
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = data.aws_region.current.name
  k8s_cluster_name = data.aws_eks_cluster.target.name
}

#module "nginx-controller" {
#  source = "terraform-iaac/nginx-controller/helm"
#
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
#    }
#  ]
#}
#--------------------------------------------------------