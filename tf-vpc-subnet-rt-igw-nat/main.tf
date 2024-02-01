# Create a new VPC
resource "aws_vpc" "ecs_vpc_prsnr_tf" {
  cidr_block = "172.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "ecs-vps-provnr-tf"
  }
}

# Create the two public subnets in different availability zones
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.ecs_vpc_prsnr_tf.id
  cidr_block = "172.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.ecs_vpc_prsnr_tf.id
  cidr_block = "172.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Create the two private subnets in different availability zones
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.ecs_vpc_prsnr_tf.id
  cidr_block = "172.0.3.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.ecs_vpc_prsnr_tf.id
  cidr_block = "172.0.4.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "private-subnet-2"
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc_prsnr_tf.id
  tags = {
    Name = "ecs-igw-prsnr-tf"
  }
}

# Create a NAT Gateway
resource "aws_nat_gateway" "ecs_nat_gateway" {
  allocation_id = aws_eip.ecs_eip.id
  subnet_id     = aws_subnet.private_subnet_1.id
}


# Create a route table for the public subnets and add a route to the Internet Gateway
resource "aws_route_table" "ecs_public_rt" {
  vpc_id = aws_vpc.ecs_vpc_prsnr_tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "ecs_public_rta_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.ecs_public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.ecs_public_rt.id
}

# Create a route table for the private subnets
resource "aws_route_table" "ecs_private_rt" {
  vpc_id = aws_vpc.ecs_vpc_prsnr_tf.id
  tags = {
    Name = "private-rt"
  }
    route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ecs_nat_gateway.id
  }
}

# Associate the private route table with the private subnets
resource "aws_route_table_association" "private_rta_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.ecs_private_rt.id
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.ecs_private_rt.id
}

# Allocate an Elastic IP address for the NAT Gateway.
resource "aws_eip" "ecs_eip" {
  vpc = true
}
