output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}
output "cluster_id" {
  value = aws_eks_cluster.eks.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "aws_iam_role" {
  value = aws_iam_role.eks-iam-role.arn
}