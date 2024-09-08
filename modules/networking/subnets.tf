data "aws_availability_zones" "all" {}

# Public Subnet 1
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.base_cidr_block,8,1)
  availability_zone = data.aws_availability_zones.all.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }

  depends_on = [ aws_vpc.main ]
}


# Public Subnet 2
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.base_cidr_block,8,2)
  availability_zone = data.aws_availability_zones.all.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }

  depends_on = [ aws_vpc.main ]
}

# Private Subnet 1
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.base_cidr_block,8,3)
  availability_zone = data.aws_availability_zones.all.names[0]

  tags = {
    Name = "private-subnet-1"
  }

  depends_on = [ aws_vpc.main ]
}

# Private Subnet 2
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.base_cidr_block,8,4)
  availability_zone = data.aws_availability_zones.all.names[1]
  
  tags = {
    Name = "private-subnet-2"
  }

  depends_on = [ aws_vpc.main ]
}

# RDS Subnet 1
resource "aws_subnet" "rds1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.base_cidr_block,8,5)
  availability_zone = data.aws_availability_zones.all.names[0]

  tags = {
    Name = "rds-private-subnet-1"
  }

  depends_on = [ aws_vpc.main ]
}

# RDS Subnet 2
resource "aws_subnet" "rds2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.base_cidr_block,8,6)
  availability_zone = data.aws_availability_zones.all.names[1]
  
  tags = {
    Name = "rds-private-subnet-2"
  }

  depends_on = [ aws_vpc.main ]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
}

# Route for public subnets to the Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public Subnet Associations
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}

# Route for private subnets to the NAT Gateway
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public_nat.id
}

# Private Subnet Associations
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}


