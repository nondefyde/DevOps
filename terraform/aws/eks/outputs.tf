output "app_project_prefix" {
  value = var.app_project_prefix
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.eks_cluster_name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "issuer" {
  value = module.eks.issuer
}

output "version" {
  value = module.eks.version
}