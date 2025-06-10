# modules/vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "${var.env}-vpc" }
}
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.env}-igw" }
}
# Tabla de rutas públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route { cidr_block = "0.0.0.0/0" gateway_id = aws_internet_gateway.igw.id }
  tags = { Name = "${var.env}-public-rt" }
}
