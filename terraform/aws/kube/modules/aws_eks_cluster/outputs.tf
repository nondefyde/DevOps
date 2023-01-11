output "cluster_endpoint" {
  value = aws_eks_cluster.k8_cluster.endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.k8_cluster.certificate_authority[0].data
}