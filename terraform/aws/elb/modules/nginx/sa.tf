
resource "aws_iam_role" "role_service_account" {
  name = "${var.project}-aws-nginx-role"
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


resource "aws_iam_role_policy_attachment" "eks-iam-role-1-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.role_service_account.name
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
    aws_iam_role.role_service_account
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