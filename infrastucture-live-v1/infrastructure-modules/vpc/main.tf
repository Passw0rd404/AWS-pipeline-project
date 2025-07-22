
# Data source to get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Public Subnet 1 (First AZ)
resource "aws_subnet" "pub_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.pub_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-1"
    Type = "Public"
  }
}

# Public Subnet 2 (Second AZ)
resource "aws_subnet" "pub_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.pub_2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-subnet-2"
    Type = "Public"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "pub-route-table"
  }
}

# Route Table Association for Public Subnet 1
resource "aws_route_table_association" "pub_1" {
  subnet_id      = aws_subnet.pub_1.id
  route_table_id = aws_route_table.pub.id
}

# Route Table Association for Public Subnet 2
resource "aws_route_table_association" "pub_2" {
  subnet_id      = aws_subnet.pub_2.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "the security group for the load balancer and the instaces"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "example"
  }
}

# This gets your current public IP
data "http" "my_ip" {
    url = "https://api.ipify.org"
}

# SSH access from anywhere (0.0.0.0/0)
resource "aws_vpc_security_group_ingress_rule" "ssh_from_my_ip" {
  security_group_id = aws_security_group.app_sg.id
  description       = "SSH access from my ip"
  
  cidr_ipv4   = "${chomp(data.http.my_ip.response_body)}/32"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = {
    Name = "SSH from my ip"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_port" {
  security_group_id = aws_security_group.app_sg.id
  description       = "required port"
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8002
  to_port     = 8002
  ip_protocol = "tcp"

  tags = {
    Name = "app_port"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_rule" {
  security_group_id = aws_security_group.app_sg.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name = "https_rule"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http_rule" {
  security_group_id = aws_security_group.app_sg.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name = "http_rule"
  }
}

# Optional: Egress rule for outbound traffic (if not using default)
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow all outbound traffic"
  
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"  # All protocols

  tags = {
    Name = "All outbound traffic"
  }
}
