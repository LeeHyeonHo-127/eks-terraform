output "vpc_id" {
  value = aws_vpc.main.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

output "eks_subnet_ids" {
  value = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
}

output "eks_public_subnet_ids" {
  description = "ALB 가 Private Subnet과 연결하기위해서 필요한 서브넷"
  value = [
    aws_subnet.public1.id,
    aws_subnet.public2.id,
  ]
}

output "rds_primary_subnet_id" {
  value = aws_subnet.rds1.id
}

output "rds_secondary_subnet_id" {
  value = aws_subnet.rds2.id
}