resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  tags = {
    Name = "siemens-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "siemens-ig"
  }
}

# Public Subnet
resource "aws_subnet" "subnet-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-a
  availability_zone = "${var.region}a"
  tags = {
    Name = "siemens-private-subnet-a"
  }
}

resource "aws_subnet" "subnet-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-b
  availability_zone = "${var.region}b"
  tags = {
    Name = "siemens-public-subnet-b"
  }
  
}

resource "aws_subnet" "subnet-c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-c
  availability_zone = "${var.region}c"
  tags = {
    Name = "siemens-public-subnet-c"
  }
}

# Private Subnets

resource "aws_subnet" "private-subnet-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.psubnet-cidr-a
  availability_zone = "${var.region}a"
  tags = {
    Name = "siemens-private-subnet-a"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.psubnet-cidr-b
  availability_zone = "${var.region}b"
  tags = {
    Name = "siemens-private-subnet-b"
  }
}

resource "aws_subnet" "private-subnet-c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.psubnet-cidr-c
  availability_zone = "${var.region}c"
  tags = {
    Name = "siemens-private-subnet-c"
  }
}


# Public-subnet-route-table

resource "aws_route_table" "public-subnet-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "siemens-public-rt"
  }
}


#Private-subnet-a-route-table 
resource "aws_route_table" "private-subnet-a-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.siemens-nat-gw-a.id
  }
  tags = {
    Name = "siemens-private-a-rt"
  }
}

#Private-subnet-b-route-table 
resource "aws_route_table" "private-subnet-b-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.siemens-nat-gw-b.id
  }
  tags = {
    Name = "siemens-private-b-rt"
  }
}

#Private-subnet-c-route-table 
resource "aws_route_table" "private-subnet-c-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.siemens-nat-gw-c.id
  }
  tags = {
    Name = "siemens-private-c-rt"
  }
}


resource "aws_route_table_association" "subnet-a-route-table-association" {
  subnet_id      = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "subnet-b-route-table-association" {
  subnet_id      = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "subnet-c-route-table-association" {
  subnet_id      = aws_subnet.subnet-c.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}




resource "aws_route_table_association" "private-subnet-a-route-table-association" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-subnet-a-route-table.id
}

resource "aws_route_table_association" "private-subnet-b-route-table-association" {
  subnet_id      = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.private-subnet-b-route-table.id
}

resource "aws_route_table_association" "private-subnet-c-route-table-association" {
  subnet_id      = aws_subnet.private-subnet-c.id
  route_table_id = aws_route_table.private-subnet-c-route-table.id
}





resource "aws_eip" "private-subnet-a-eip" {
  vpc = true
  tags = {
    Name = "private-subnet-a-eip"
  }
}

resource "aws_nat_gateway" "siemens-nat-gw-a" {
  allocation_id = aws_eip.private-subnet-a-eip.id
  subnet_id     = aws_subnet.private-subnet-a.id
  tags = {
    Name = "siemens-nat-gw-a"
  }
}


resource "aws_eip" "private-subnet-b-eip" {
  vpc = true
  tags = {
    Name = "private-subnet-b-eip"
  }
}

resource "aws_nat_gateway" "siemens-nat-gw-b" {
  allocation_id = aws_eip.private-subnet-b-eip.id
  subnet_id     = aws_subnet.private-subnet-b.id
  tags = {
    Name = "siemens-nat-gw-b"
  }
}

resource "aws_eip" "private-subnet-c-eip" {
  vpc = true
  tags = {
    Name = "private-subnet-c-eip"
  }
}

resource "aws_nat_gateway" "siemens-nat-gw-c" {
  allocation_id = aws_eip.private-subnet-c-eip.id
  subnet_id     = aws_subnet.private-subnet-c.id
  tags = {
    Name = "siemens-nat-gw-c"
  }
}