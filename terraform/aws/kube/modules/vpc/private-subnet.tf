/* private subnet and routing */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets)
  cidr_block              = element(var.private_subnets, count.index)
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = false
  tags                    = {
    Name        = var.project
    Environment = var.environment
    Type        = "private_subnet"
  }
}

resource "aws_ec2_tag" "private_subnet_cluster_tag" {
  count       = length(var.private_subnets)
  resource_id = aws_subnet.private_subnet[count.index].id
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_tag" {
  count       = length(var.private_subnets)
  resource_id = aws_subnet.private_subnet[count.index].id
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags   = {
    Name        = var.project,
    Environment = var.environment
  }
}

resource "aws_route" "private_internet_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

/* Route table associations */
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}