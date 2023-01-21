resource "aws_security_group" "eks" {
  name        = "${var.prefix} eks cluster"
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "World"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
    Name = "EKS ${var.prefix}",
    "kubernetes.io/cluster/${local.prefix}": "owned"
  }, var.tags)
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.19.0"

  cluster_name                    = var.eks_cluster_name
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_additional_security_group_ids = [aws_security_group.eks.id]

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["t3.medium", "t3.large"]
    vpc_security_group_ids = [aws_security_group.eks.id]
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 3

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      labels = var.tags
      taints = {
      }
      tags = var.tags
    }
  }

  tags = var.tags
}

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
#
#resource "aws_eks_cluster" "k8_cluster" {
#  name     = var.eks_cluster_name
#  role_arn = aws_iam_role.k8_cluster_role.arn
#
#  vpc_config {
#    subnet_ids = var.vpc_subnet_ids
#  }
#
#  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
#  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#  depends_on = [
#    aws_iam_role_policy_attachment.k8_EKSClusterPolicy,
#    aws_iam_role_policy_attachment.k8_EKSVPCResource,
#  ]
#}
#
#resource "aws_eks_node_group" "k8_cluster_nodegroup_one" {
#  cluster_name    = aws_eks_cluster.k8_cluster.name
#  node_group_name = var.eks_nodegroup_one_name
#  node_role_arn   = aws_iam_role.k8_nodegroup_role.arn
#  subnet_ids      = var.vpc_subnet_ids
#
#  scaling_config {
#    desired_size = 2
#    max_size     = 4
#    min_size     = 1
#  }
#
#  update_config {
#    max_unavailable = 2
#  }
#
#  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#  depends_on = [
#    aws_iam_role_policy_attachment.eks_worker_node_policy,
#    aws_iam_role_policy_attachment.eks_cni_policy,
#    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
#  ]
#}