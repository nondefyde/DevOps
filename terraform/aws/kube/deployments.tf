#provider "kubernetes" {
#  host                   = "https://${module.aws_eks_cluster.cluster_endpoint}"
#  token                  = data.google_client_config.provider.access_token
#  cluster_ca_certificate = base64decode(module.gke_module.gke_ca_certificate)
#}
#
#resource "kubernetes_namespace_v1" "namespace" {
#  metadata {
#    name = var.namespace
#  }
#  depends_on = [module.gke_module]
#}
#
##--------------Ingress Controller----------------------
#provider "helm" {
#  kubernetes {
#    host                   = "https://${module.gke_module.gke_endpoint}"
#    token                  = data.google_client_config.provider.access_token
#    cluster_ca_certificate = base64decode(module.gke_module.gke_ca_certificate)
#  }
#}
#
#resource "google_compute_address" "ingress_ip_address" {
#  name       = var.ip_address_name
#  depends_on = [module.gke_module]
#}
#module "nginx-controller" {
#  namespace       = kubernetes_namespace_v1.namespace.metadata.0.name
#  controller_kind = "Deployment"
#  source          = "terraform-iaac/nginx-controller/helm"
#  ip_address      = google_compute_address.ingress_ip_address.address
#}
##--------------------------------------------------------
#
#
###--------------Deployments----------------------
#resource "kubernetes_deployment_v1" "deployment" {
#  metadata {
#    name      = "${var.app_name}-dpl"
#    namespace = kubernetes_namespace_v1.namespace.metadata.0.name
#    labels    = {
#      app = var.app_name
#    }
#  }
#
#  spec {
#    replicas = 1
#    selector {
#      match_labels = {
#        app = "${var.app_name}-pod"
#      }
#    }
#    template {
#      metadata {
#        labels = {
#          app = "${var.app_name}-pod"
#        }
#      }
#      spec {
#        security_context {
#          run_as_non_root = false
#          run_as_user     = 0
#        }
#        container {
#          image             = "${var.image_name}:${var.image_tag}"
#          name              = var.app_name
#          image_pull_policy = "Always"
#          port {
#            container_port = var.app_port
#            protocol       = "TCP"
#          }
#        }
#      }
#    }
#  }
#}
#
#resource "kubernetes_service_v1" "service" {
#  metadata {
#    name      = "${var.app_name}-srv"
#    namespace = kubernetes_namespace_v1.namespace.metadata.0.name
#  }
#  spec {
#    selector = {
#      app = "${var.app_name}-pod"
#    }
#    port {
#      port        = var.app_port
#      target_port = var.app_port
#      protocol    = "TCP"
#    }
#  }
#}
#
#resource "kubernetes_ingress_v1" "ingress" {
#  metadata {
#    name      = "${var.app_name}-ingress"
#    namespace = kubernetes_namespace_v1.namespace.metadata.0.name
#    labels    = {
#      app = var.app_name
#    }
#  }
#
#  spec {
#    ingress_class_name = module.nginx-controller.name
#    rule {
#      host = var.ingress_host
#      http {
#        path {
#          path      = "/"
#          path_type = "Prefix"
#          backend {
#            service {
#              name = "${var.app_name}-srv"
#              port {
#                number = var.app_port
#              }
#            }
#          }
#        }
#      }
#    }
#  }
#}
