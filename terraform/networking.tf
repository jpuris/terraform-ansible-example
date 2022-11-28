# Get region's availability zone metadata
data "aws_availability_zones" "available" {}

# Define local variables
locals {
  azs       = data.aws_availability_zones.available.names
  access_ip = "${chomp(data.http.my_public_ip.response_body)}/32"
}

# Random ID for resources in order to avoid conflicts with existing ones
resource "random_id" "random" {
  byte_length = 2
}

# AWS VPC that will contain the EC2 instance
resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    terraform = "true"
    Name      = "demo-${random_id.random.dec}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Internet access for the VPC
resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
  tags = {
    "Name" = "demo-${random_id.random.dec}"
  }
}

# Public routes for the VPC
resource "aws_route_table" "demo_public_rt" {
  vpc_id = aws_vpc.demo.id
  tags = {
    "Name" = "demo-public-rt"
  }
}

# Public route's default route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.demo_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.demo.id
}

# Private route for the VPC
resource "aws_default_route_table" "demo_private_rt" {
  default_route_table_id = aws_vpc.demo.default_route_table_id
  tags = {
    "Name" = "demo-private"
  }
}

# VPC's Public subnet in every AZ
resource "aws_subnet" "demo_public_subnet" {
  count  = length(local.azs)
  vpc_id = aws_vpc.demo.id
  # VPC's CIDR's /24 network across all AZs
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]
  tags = {
    "Name" = "demo-public-${count.index + 1}"
  }
}

# VPC's Private subnet in every AZ
resource "aws_subnet" "demo_private_subnet" {
  count  = length(local.azs)
  vpc_id = aws_vpc.demo.id
  # VPC's CIDR incremental /16 across a /24 network
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
  map_public_ip_on_launch = false
  availability_zone       = local.azs[count.index]
  tags = {
    "Name" = "demo-private-${count.index + 1}"
  }
}

# Attache the Public routing table to every Public subnet
resource "aws_route_table_association" "demo_public_assoc" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.demo_public_subnet[count.index].id
  route_table_id = aws_route_table.demo_public_rt.id
}

# VPC's public network firewall
resource "aws_security_group" "demo_security_group" {
  name        = "public_sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.demo.id
}

# VPC's public network firewall rule for incoming connections
resource "aws_security_group_rule" "ingress_all" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"
  # Allows the VPC to be talked to only by the Public IP from where tf was run
  cidr_blocks       = [local.access_ip]
  security_group_id = aws_security_group.demo_security_group.id
}

# VPC's public network firewall rule for outgoing connections
resource "aws_security_group_rule" "egress_all" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"
  # Allow the VPC to talk to anyone outside
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.demo_security_group.id
}