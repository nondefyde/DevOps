output "public_ip_address" {
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

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "caller_id" {
  value = data.aws_caller_identity.current.id
}

output "issuer" {
  value = module.eks.issuer
}

output "module_path" {
  value = path.module
}

output "version" {
  value = module.eks.version
}