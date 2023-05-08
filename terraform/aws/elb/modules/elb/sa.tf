
resource "aws_iam_role" "role_service_account" {
  name = "${var.project}-aws-elb-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement" : [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${var.account_id}:oidc-provider/${var.issuer}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${var.issuer}:aud": "sts.amazonaws.com",
            "${var.issuer}:sub": "system:serviceaccount:${var.sa_namespace}:${var.sa_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-iam-role-1-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.role_service_account.name
}

resource "aws_iam_role_policy_attachment" "eks-iam-role-1-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.role_service_account.name
}

resource "aws_iam_role_policy_attachment" "eks-iam-role-1-EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.role_service_account.name
}

resource "aws_iam_role_policy_attachment" "eks-iam-role-1-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.role_service_account.name
}

#resource "aws_iam_policy" "elb-policy" {
#  name        = "${var.project}-aws-elb-policy"
#  path        = "/"
#  description = "ALB eks iam policy"
#
#  # Terraform's "jsonencode" function converts a
#  # Terraform expression result to valid JSON syntax.
#  policy = jsonencode({
#    "Version": "2012-10-17",
#    "Statement": [
#      {
#        "Effect": "Allow",
#        "Action": [
#          "iam:CreateServiceLinkedRole"
#        ],
#        "Resource": "*",
#        "Condition": {
#          "StringEquals": {
#            "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
#          }
#        }
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "ec2:DescribeAccountAttributes",
#          "ec2:DescribeAddresses",
#          "ec2:DescribeAvailabilityZones",
#          "ec2:DescribeInternetGateways",
#          "ec2:DescribeVpcs",
#          "ec2:DescribeVpcPeeringConnections",
#          "ec2:DescribeSubnets",
#          "ec2:DescribeSecurityGroups",
#          "ec2:DescribeInstances",
#          "ec2:DescribeNetworkInterfaces",
#          "ec2:DescribeTags",
#          "ec2:GetCoipPoolUsage",
#          "ec2:DescribeCoipPools",
#          "elasticloadbalancing:DescribeLoadBalancers",
#          "elasticloadbalancing:DescribeLoadBalancerAttributes",
#          "elasticloadbalancing:DescribeListeners",
#          "elasticloadbalancing:DescribeListenerCertificates",
#          "elasticloadbalancing:DescribeSSLPolicies",
#          "elasticloadbalancing:DescribeRules",
#          "elasticloadbalancing:DescribeTargetGroups",
#          "elasticloadbalancing:DescribeTargetGroupAttributes",
#          "elasticloadbalancing:DescribeTargetHealth",
#          "elasticloadbalancing:DescribeTags"
#        ],
#        "Resource": "*"
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "cognito-idp:DescribeUserPoolClient",
#          "acm:ListCertificates",
#          "acm:DescribeCertificate",
#          "iam:ListServerCertificates",
#          "iam:GetServerCertificate",
#          "waf-regional:GetWebACL",
#          "waf-regional:GetWebACLForResource",
#          "waf-regional:AssociateWebACL",
#          "waf-regional:DisassociateWebACL",
#          "wafv2:GetWebACL",
#          "wafv2:GetWebACLForResource",
#          "wafv2:AssociateWebACL",
#          "wafv2:DisassociateWebACL",
#          "shield:GetSubscriptionState",
#          "shield:DescribeProtection",
#          "shield:CreateProtection",
#          "shield:DeleteProtection"
#        ],
#        "Resource": "*"
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "ec2:AuthorizeSecurityGroupIngress",
#          "ec2:RevokeSecurityGroupIngress"
#        ],
#        "Resource": "*"
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "ec2:CreateSecurityGroup"
#        ],
#        "Resource": "*"
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "ec2:CreateTags"
#        ],
#        "Resource": "arn:aws:ec2:*:*:security-group/*",
#        "Condition": {
#          "StringEquals": {
#            "ec2:CreateAction": "CreateSecurityGroup"
#          },
#          "Null": {
#            "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
#          }
#        }
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "ec2:CreateTags",
#          "ec2:DeleteTags"
#        ],
#        "Resource": "arn:aws:ec2:*:*:security-group/*",
#        "Condition": {
#          "Null": {
#            "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
#            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#          }
#        }
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "ec2:AuthorizeSecurityGroupIngress",
#          "ec2:RevokeSecurityGroupIngress",
#          "ec2:DeleteSecurityGroup"
#        ],
#        "Resource": "*",
#        "Condition": {
#          "Null": {
#            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#          }
#        }
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "elasticloadbalancing:CreateLoadBalancer",
#          "elasticloadbalancing:CreateTargetGroup"
#        ],
#        "Resource": "*",
#        "Condition": {
#          "Null": {
#            "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
#          }
#        }
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "elasticloadbalancing:CreateListener",
#          "elasticloadbalancing:DeleteListener",
#          "elasticloadbalancing:CreateRule",
#          "elasticloadbalancing:DeleteRule"
#        ],
#        "Resource": "*"
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "elasticloadbalancing:AddTags",
#          "elasticloadbalancing:RemoveTags"
#        ],
#        "Resource": [
#          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
#          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
#          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
#        ],
#        "Condition": {
#          "Null": {
#            "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
#            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#          }
#        }
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "elasticloadbalancing:AddTags",
#          "elasticloadbalancing:RemoveTags"
#        ],
#        "Resource": [
#          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
#          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
#          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
#          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
#        ]
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "elasticloadbalancing:ModifyLoadBalancerAttributes",
#          "elasticloadbalancing:SetIpAddressType",
#          "elasticloadbalancing:SetSecurityGroups",
#          "elasticloadbalancing:SetSubnets",
#          "elasticloadbalancing:DeleteLoadBalancer",
#          "elasticloadbalancing:ModifyTargetGroup",
#          "elasticloadbalancing:ModifyTargetGroupAttributes",
#          "elasticloadbalancing:DeleteTargetGroup"
#        ],
#        "Resource": "*",
#        "Condition": {
#          "Null": {
#            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#          }
#        }
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "elasticloadbalancing:RegisterTargets",
#          "elasticloadbalancing:DeregisterTargets"
#        ],
#        "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
#      },
#      {
#        "Effect": "Allow",
#        "Action": [
#          "elasticloadbalancing:SetWebAcl",
#          "elasticloadbalancing:ModifyListener",
#          "elasticloadbalancing:AddListenerCertificates",
#          "elasticloadbalancing:RemoveListenerCertificates",
#          "elasticloadbalancing:ModifyRule"
#        ],
#        "Resource": "*"
#      }
#    ]
#  })
#}
#
#resource "aws_iam_role_policy_attachment" "policy_attachment_service_account" {
#  policy_arn = aws_iam_policy.elb-policy.arn
#  role = aws_iam_role.role_service_account.name
#}

resource "kubernetes_secret" "elb_secret" {
  metadata {
    name = var.sa_name
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name = var.sa_name
    namespace = var.sa_namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.role_service_account.arn
    }

    labels = {
      "app.kubernetes.io/name" = var.sa_name
      "app.kubernetes.io/component" = "controller"
    }
  }

  automount_service_account_token = true

  depends_on = [
    kubernetes_secret.elb_secret,
    aws_iam_role_policy_attachment.eks-iam-role-1-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-iam-role-1-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-iam-role-1-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-iam-role-1-EC2InstanceProfileForImageBuilderECRContainerBuilds
  ]
}

resource "kubernetes_secret_v1" "service_account_token" {
  metadata {
    name = var.sa_name
    namespace = var.sa_namespace
    annotations = {
      "kubernetes.io/service-account.name" = var.sa_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.service_account
  ]
}

data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "tls_certificate" "tls" {
  url = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
}