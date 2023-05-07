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

output "vpc_id" {
  value = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
}

output "caller_id" {
  value = data.aws_caller_identity.current.id
}

output "issuer" {
  value = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

output "default_secret_name" {
  value = module.elb.default_secret_name
}