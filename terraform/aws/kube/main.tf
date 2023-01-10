terraform {
#  backend "azurerm" {}
  required_version = ">=0.12"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.49.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_key_id
  secret_key = var.aws_key_secret
}

resource "aws_vpc" "k8_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_iam_role" "k8_role" {
  name = "${var.app_project_prefix}-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.k8_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}