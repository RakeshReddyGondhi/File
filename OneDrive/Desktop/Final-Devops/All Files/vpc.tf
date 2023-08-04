provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main VPC Internet Gateway"
  }
}

resource "aws_subnet" "public1" {
  count         = 1
  vpc_id        = aws_vpc.main.id
  cidr_block    = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet-1"
  }
}

resource "aws_subnet" "private1" {
  count         = 1
  vpc_id        = aws_vpc.main.id
  cidr_block    = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet-1"
  }
}

resource "aws_subnet" "public2" {
  count         = 1
  vpc_id        = aws_vpc.main.id
  cidr_block    = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet-2"
  }
}

resource "aws_subnet" "private2" {
  count         = 1
  vpc_id        = aws_vpc.main.id
  cidr_block    = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet-2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "public1" {
  count          = 1
  subnet_id      = aws_subnet.public1[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  count          = 1
  subnet_id      = aws_subnet.public2[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private Subnet Route Table"
  }
}

resource "aws_route_table_association" "private1" {
  count          = 1
  subnet_id      = aws_subnet.private1[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  count          = 1
  subnet_id      = aws_subnet.private2[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_nat_gateway" "gw" {
  count         = 1
  subnet_id     = aws_subnet.public1[count.index].id
  allocation_id = aws_eip.nat[count.index].id

  tags = {
    Name = "NAT Gateway"
  }
}

resource "aws_eip" "nat" {
  count = 1

  tags = {
    Name = "NAT Elastic IP"
  }
}

resource "aws_route" "private_nat" {
  count          = 1
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw[count.index].id
}


