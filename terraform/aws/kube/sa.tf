#resource "null_resource" "associate_iam_oidc_provider" {
#  provisioner "local-exec" {
#    command = "eksctl utils associate-iam-oidc-provider --region=${var.aws_region} --cluster=${local.eks_cluster_name} --approve"
#  }
#
#  depends_on = [
#    module.eks,
#    aws_iam_policy.elb-policy
#  ]
#}


resource "aws_iam_role" "role_service_account" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement" : [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.issuer}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${module.eks.issuer}:aud": "sts.amazonaws.com",
            "${module.eks.issuer}:sub": "system:serviceaccount:${var.sa_namespace}:${var.sa_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "elb-policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "ALB eks iam policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iam:CreateServiceLinkedRole"
        ],
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateSecurityGroup"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateTags"
        ],
        "Resource": "arn:aws:ec2:*:*:security-group/*",
        "Condition": {
          "StringEquals": {
            "ec2:CreateAction": "CreateSecurityGroup"
          },
          "Null": {
            "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Resource": "arn:aws:ec2:*:*:security-group/*",
        "Condition": {
          "Null": {
            "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ],
        "Resource": "*",
        "Condition": {
          "Null": {
            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ],
        "Resource": "*",
        "Condition": {
          "Null": {
            "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource": [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ],
        "Condition": {
          "Null": {
            "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource": [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup"
        ],
        "Resource": "*",
        "Condition": {
          "Null": {
            "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule"
        ],
        "Resource": "*"
      }
    ]
  })

  depends_on = [
    module.eks
  ]
}

resource "aws_iam_role_policy_attachment" "policy_attachment_service_account" {
  policy_arn = aws_iam_policy.elb-policy.arn
  role = aws_iam_role.role_service_account.name
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name = "aws-load-balancer-controller"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.role_service_account.arn
    }
    namespace = var.sa_namespace
  }

  depends_on = [
    module.eks,
    null_resource.associate_iam_oidc_provider,
    aws_iam_role_policy_attachment.policy_attachment_service_account
  ]
}