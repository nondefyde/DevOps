resource "kubectl_manifest" "targetgroupbindings" {
  yaml_body = file("${path.module}/yamls/nginx.yaml")

  wait = true
}