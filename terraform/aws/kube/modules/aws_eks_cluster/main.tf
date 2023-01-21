
module "lb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.env_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_eks_cluster" "k8_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.k8_cluster_role.arn

  vpc_config {
    subnet_ids = var.vpc_subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.k8_EKSClusterPolicy,
    aws_iam_role_policy_attachment.k8_EKSVPCResource,
  ]
}

resource "aws_eks_node_group" "k8_cluster_nodegroup_one" {
  cluster_name    = aws_eks_cluster.k8_cluster.name
  node_group_name = var.eks_nodegroup_one_name
  node_role_arn   = aws_iam_role.k8_nodegroup_role.arn
  subnet_ids      = var.vpc_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
  ]
}