terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Create the VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.name}-public-subnet-${count.index}"
  })
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, {
    Name = "${var.name}-private-subnet-${count.index}"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_subnets)
  vpc   = true
  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip-${count.index}"
  })
}

# Create NAT Gateways
resource "aws_nat_gateway" "this" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = merge(var.tags, {
    Name = "${var.name}-nat-gw-${count.index}"
  })
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

# Add route to Internet Gateway in public route table
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create private route tables
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name}-private-rt-${count.index}"
  })
}

# Add route to NAT Gateway in private route tables
resource "aws_route" "private_nat_gateway" {
  count                  = length(var.private_subnets)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

# Associate private subnets with the private route tables
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Create a security group for the load balancer
resource "aws_security_group" "lb_sg" {
  name        = "${var.name}-lb-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-lb-sg"
  })
}

# # module "vpc" {
# #   source = "terraform-aws-modules/vpc/aws"
# #
# #   name = "my-vpc"
# #   cidr = "10.0.0.0/16"
# #
# #   azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
# #   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# #   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
# #
# #   enable_nat_gateway = true
# #   enable_vpn_gateway = true
# #
# #   tags = {
# #     Terraform = "true"
# #     Environment = "dev"
# #   }
# # }
#
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }
#
# resource "aws_vpc" "this" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_support   = true
#   enable_dns_hostnames = true
#   tags = merge(var.tags, {
#     Name = "${var.name}-vpc"
#   })
# }
#
# resource "aws_subnet" "public" {
#   count                   = length(var.public_subnets)
#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = var.public_subnets[count.index]
#   availability_zone       = var.azs[count.index]
#   map_public_ip_on_launch = true
#   tags = merge(var.tags, {
#     Name = "${var.name}-public-subnet-${count.index}"
#   })
# }
#
# resource "aws_subnet" "private" {
#   count             = length(var.private_subnets)
#   vpc_id            = aws_vpc.this.id
#   cidr_block        = var.private_subnets[count.index]
#   availability_zone = var.azs[count.index]
#   tags = merge(var.tags, {
#     Name = "${var.name}-private-subnet-${count.index}"
#   })
# }
#
# resource "aws_internet_gateway" "this" {
#   vpc_id = aws_vpc.this.id
#   tags = merge(var.tags, {
#     Name = "${var.name}-igw"
#   })
# }
#
# resource "aws_nat_gateway" "this" {
#   count         = length(var.public_subnets)
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id
#   tags = merge(var.tags, {
#     Name = "${var.name}-nat-gw-${count.index}"
#   })
# }
#
# resource "aws_eip" "nat" {
#   count = length(var.public_subnets)
#   vpc   = true
#   tags = merge(var.tags, {
#     Name = "${var.name}-nat-eip-${count.index}"
#   })
# }
#
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.this.id
#   tags = merge(var.tags, {
#     Name = "${var.name}-public-rt"
#   })
# }
#
# resource "aws_route" "public_internet_gateway" {
#   route_table_id         = aws_route_table.public.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.this.id
# }
#
# resource "aws_route_table_association" "public" {
#   count          = length(var.public_subnets)
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }
#
# resource "aws_route_table" "private" {
#   count  = length(var.private_subnets)
#   vpc_id = aws_vpc.this.id
#   tags = merge(var.tags, {
#     Name = "${var.name}-private-rt-${count.index}"
#   })
# }
#
# resource "aws_route" "private_nat_gateway" {
#   count                  = length(var.private_subnets)
#   route_table_id         = aws_route_table.private[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.this[count.index].id
# }
#
# resource "aws_route_table_association" "private" {
#   count          = length(var.private_subnets)
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private[count.index].id
# }