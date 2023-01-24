#////////////////////////////////// Cert Manager //////////////////////////////////////////////
#data "kubectl_file_documents" "cert-manager-yml" {
#  content = file("${path.module}/yamls/cert-manager.yaml")
#}
#
#resource "kubectl_manifest" "cert-manager" {
#  count     = length(data.kubectl_file_documents.cert-manager-yml.documents)
#  yaml_body = element(data.kubectl_file_documents.cert-manager-yml.documents, count.index)
#
#  wait = true
#
#  depends_on = [
#    module.eks,
#    kubernetes_service_account.service_account
#  ]
#}
#
#///////////////// Elastic Load Balancer //////////////////////
#data "kubectl_file_documents" "elb-controller-yml" {
#  content = templatefile("${path.module}/yamls/elb-spec.yaml.tpl", {
#    cluster_name : local.eks_cluster_name,
#    aws_region : var.aws_region,
#    vpc_id : module.vpc.vpc_id,
#  })
#}
#
#data "kubectl_file_documents" "elb-controller-yml-count" {
#  content = file("${path.module}/yamls/elb-spec.yaml")
#}
#
#resource "kubectl_manifest" "elb-controller" {
#  count     = length(data.kubectl_file_documents.elb-controller-yml-count.documents)
#  yaml_body = element(data.kubectl_file_documents.elb-controller-yml.documents, count.index)
#
#  wait = true
#
#  depends_on = [
#    kubectl_manifest.cert-manager
#  ]
#}
#
#data "kubectl_file_documents" "ingress-controller-yml" {
#  content = file("${path.module}/yamls/ingclass.yaml")
#}
#
#resource "kubectl_manifest" "ingress-controller" {
#  count     = length(data.kubectl_file_documents.ingress-controller-yml.documents)
#  yaml_body = element(data.kubectl_file_documents.ingress-controller-yml.documents, count.index)
#
#  wait = true
#
#  depends_on = [
#    kubectl_manifest.elb-controller,
#  ]
#}
#
#data "kubectl_file_documents" "nginx-ingress-yml" {
#  content = file("${path.module}/yamls/nginx.yaml")
#}
#
#resource "kubectl_manifest" "nginx-ingress" {
#  count     = length(data.kubectl_file_documents.nginx-ingress-yml.documents)
#  yaml_body = element(data.kubectl_file_documents.nginx-ingress-yml.documents, count.index)
#
#  wait = true
#
#  depends_on = [
#    kubectl_manifest.ingress-controller,
#  ]
#}