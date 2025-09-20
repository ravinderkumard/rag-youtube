# -----------------------
# VPC and Networking Setup
# -----------------------

# Create VPC
resource "aws_vpc" "rag_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "rag-vpc"
  }
}

# Create Internet Gateway for internet access
resource "aws_internet_gateway" "rag_igw" {
  vpc_id = aws_vpc.rag_vpc.id

  tags = {
    Name = "rag-igw"
  }
}

# Create two public subnets across availability zones
resource "aws_subnet" "rag_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.rag_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.rag_vpc.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch  = true

  tags = {
    Name = "rag-subnet-${count.index}"
  }
}

# Route Table for public subnets
resource "aws_route_table" "rag_rt" {
  vpc_id = aws_vpc.rag_vpc.id

  tags = {
    Name = "rag-rt"
  }
}

# Add default route to the Internet Gateway
resource "aws_route" "rag_default_route" {
  route_table_id         = aws_route_table.rag_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.rag_igw.id
}

# Associate route table with each public subnet
resource "aws_route_table_association" "rag_rt_assoc" {
  count          = length(aws_subnet.rag_subnet)
  subnet_id      = aws_subnet.rag_subnet[count.index].id
  route_table_id = aws_route_table.rag_rt.id
}
