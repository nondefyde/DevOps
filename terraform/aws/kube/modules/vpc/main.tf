#######modules/vpc/main.tf
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy = var.instance_tenancy
  tags = {
    Name        = var.project
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = var.project
    Environment = var.environment
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name        = "nat"
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = 2
}