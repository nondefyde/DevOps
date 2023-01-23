resource "kubectl_manifest" "nginx-ingress-controller" {
  yaml_body = file("${path.module}/yamls/nginx.yaml")

  wait = true
}