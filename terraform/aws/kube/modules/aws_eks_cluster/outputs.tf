output "cluster_endpoint" {
  value = aws_eks_cluster.k8_cluster.endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.k8_cluster.certificate_authority[0].data
}

output "cluster_id" {
  value = aws_eks_cluster.k8_cluster.id
}

output "certificate_authority" {
  value = aws_eks_cluster.k8_cluster.certificate_authority
}

output "iam_role" {
  value       = aws_iam_role.k8_cluster_role.id
}

output "iam_node_group" {
  value       = aws_iam_role.k8_nodegroup_role.id
}