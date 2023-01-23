
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_key_id
  secret_key = var.aws_key_secret
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}