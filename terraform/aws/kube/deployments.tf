data "aws_eks_cluster_auth" "cluster" {
  name = local.eks_cluster_name
}

provider "kubernetes" {
  host                   = module.aws_eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks_cluster.kubeconfig_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}


data "tls_certificate" "cert" {
  url = module.aws_eks_cluster.eks_oidc_url
}

resource "aws_iam_openid_connect_provider" "openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cert.certificates.0.sha1_fingerprint]
  url             = module.aws_eks_cluster.eks_oidc_url
}

module "aws_lb" {
  source           = "./modules/aws_lb"
  account_id       = data.aws_caller_identity.current.account_id
  eks_cluster_name = local.eks_cluster_name
  oidc_host_path   = module.aws_eks_cluster.eks_oidc_url
  region           = var.aws_region
  vpc_id           = module.module_vpc.vpc_id

  depends_on = [aws_iam_openid_connect_provider.openid_connect_provider]
}

provider "kubectl" {
  host                   = module.aws_eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_eks_cluster.kubeconfig_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}


resource "kubectl_manifest" "ingessclassparams" {
  yaml_body = file("${path.module}/yamls/ingressclassparams.yaml")

  wait = true
}

resource "kubectl_manifest" "targetgroupbindings" {
  yaml_body = file("${path.module}/yamls/targetgroupbindings.yaml")

  wait = true
}

# V 2.4.1
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/
# helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<cluster-name>
resource "helm_release" "aws-load-balancer-controller" {
  depends_on = [kubectl_manifest.ingessclassparams, kubectl_manifest.targetgroupbindings]
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.5"
  # appVersion: v2.4.1
  #This defaults to false, recreation is required when upgrading the module from version 2.1 and lower
  force_update = var.alb_force_update

  values = [
    templatefile(
      "${path.module}/yamls/loadbalancer-values.yaml",
      {
        cluster_name         = local.eks_cluster_name
        vpc_id               = module.module_vpc.vpc_id
        region               = var.aws_region
        service_account_name = module.aws_lb.service_account_name
      }
    )
  ]
}