output "default_secret_name" {
  value = kubernetes_service_account.nginx-controller.default_secret_name
}