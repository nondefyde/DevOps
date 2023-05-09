output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.eks_cluster_name
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "vpc_id" {
  value = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
}

output "issuer" {
  value = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}
