data "aws_availability_zones" "available" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = "${var.prefix}-k8-vps"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true # enable_nat_gateway, bool, should be true to provision NAT Gateways for each the private networks
  single_nat_gateway   = true # single_nat_gateway, bool, should be true to provision a single shared NAT Gateway across all private networks
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.tag_cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.tag_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.tag_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}