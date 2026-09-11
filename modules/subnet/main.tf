# modules/subnet/main.tf

resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_cidrs : idx => cidr }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.env}-public-subnet-${each.key}"
    Environment = var.env
    Type        = "Public"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = var.public_route_table_id
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_cidrs : idx => cidr }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.env}-private-subnet-${each.key}"
    Environment = var.env
    Type        = "Private"
    ManagedBy   = "Terraform"
  }
}