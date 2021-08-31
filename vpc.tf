resource "aws_vpc" "default-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.system}-vpc"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.default-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.system}-pub-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.default-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}c"
  tags = {
    Name = "${var.system}-pub-subnet-2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.default-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.system}-pri-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.default-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}c"
  tags = {
    Name = "${var.system}-pri-subnet-2"
  }
}

resource "aws_subnet" "clientvpn" {
  vpc_id                  = aws_vpc.default-vpc.id
  cidr_block              = "10.0.8.0/22"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.system}-clientvpn-subnet"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default-vpc.id
  tags = {
    Name = "${var.system}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default-vpc.id
  tags = {
    Name = "${var.system}-pub-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default-vpc.id
  tags = {
    Name = "${var.system}-pri-rt"
  }
}

resource "aws_route_table" "clientvpn" {
  vpc_id = aws_vpc.default-vpc.id
  tags = {
    Name = "${var.system}-clientvpn-rt"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "clientvpn" {
  subnet_id      = aws_subnet.clientvpn.id
  route_table_id = aws_route_table.clientvpn.id
}
