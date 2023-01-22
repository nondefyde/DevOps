resource "aws_iam_policy" "alb-ingress-controller-iam-policy" {
  name   = "ALBIngressControllerIAMPolicy"
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role" "alb-ingress-controller-iam-role" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${var.oidc_host_path}:sub" = "system:serviceaccount:kube-system:${kubernetes_service_account.alb_ingress_controller.metadata[0].name}",
              "${var.oidc_host_path}:aud": "sts.amazonaws.com"
            }
          }
          Effect = "Allow",
          Principal = {
            Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_host_path}"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "alb-ingress-controller-iam-role-policy-attachment" {
  role       = aws_iam_role.alb-ingress-controller-iam-role.name
  policy_arn = aws_iam_policy.alb-ingress-controller-iam-policy.arn
}