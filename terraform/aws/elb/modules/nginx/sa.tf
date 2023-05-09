
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