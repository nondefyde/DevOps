
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

data "aws_eks_cluster" "eks" {
  name = local.eks_cluster_name
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_key_id
  secret_key = var.aws_key_secret
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
