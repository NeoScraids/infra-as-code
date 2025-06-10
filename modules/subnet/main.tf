# modules/subnet/main.tf
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_cidrs : idx => cidr }
  vpc_id                   = var.vpc_id
  cidr_block               = each.value
  map_public_ip_on_launch  = true
  tags = { Name = "${var.env}-public-${each.key}" }
}
# Privadas
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_cidrs : idx => cidr }
  vpc_id     = var.vpc_id
  cidr_block = each.value
  tags = { Name = "${var.env}-private-${each.key}" }
}