locals {
  vpc_name = "vpc-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# VPC 리소스
resource "aws_vpc" "main" {
  cidr_block = cidrsubnet(var.base_cidr_block, 0, 0)

  tags = {
    Name = "${local.vpc_name}"
  }
}

# 인터넷 게이트웨이 리소스
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${local.vpc_name}"
  }
}

# Elastic IP 리소스
resource "aws_eip" "ngw" {
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }
}

# NAT 게이트웨이 리소스
resource "aws_nat_gateway" "public_nat" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "NAT-Gateway-${local.vpc_name}"
  }
  depends_on = [ aws_internet_gateway.main ]
}