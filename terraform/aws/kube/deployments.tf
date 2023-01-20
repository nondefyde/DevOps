data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

provider "kubernetes" {
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

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"

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
}
#--------------------------------------------------------