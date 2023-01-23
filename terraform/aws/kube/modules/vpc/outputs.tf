###### vpc/outputs.tf 
output "aws_public_subnet" {
  value = aws_subnet.eks-public_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.eks-vpc.id
}