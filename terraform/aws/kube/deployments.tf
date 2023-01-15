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


#------------------------ Deployments -----------------------------
resource "kubernetes_deployment_v1" "deployment" {
  metadata {
    name      = "${var.app_name}-dpl"
    namespace = kubernetes_namespace_v1.namespace.metadata.0.name
    labels    = {
      app = var.app_name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${var.app_name}-pod"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.app_name}-pod"
        }
      }
      spec {
        security_context {
          run_as_non_root = false
          run_as_user     = 0
        }
        container {
          image             = "${var.image_name}:${var.image_tag}"
          name              = var.app_name
          image_pull_policy = "Always"
          port {
            container_port = var.app_port
            protocol       = "TCP"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "service" {
  metadata {
    name      = "${var.app_name}-srv"
    namespace = kubernetes_namespace_v1.namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "${var.app_name}-pod"
    }
    port {
      port        = var.app_port
      target_port = var.app_port
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "${var.app_name}-ingress"
    namespace = kubernetes_namespace_v1.namespace.metadata.0.name
    labels    = {
      app = var.app_name
    }
  }

  spec {
    ingress_class_name = module.nginx-controller.name
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "${var.app_name}-srv"
              port {
                number = var.app_port
              }
            }
          }
        }
      }
    }
  }
}
