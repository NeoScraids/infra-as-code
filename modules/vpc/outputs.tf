# modules/vpc/outputs.tf

output "vpc_id" {
  description = "Identifier of the created VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block assigned to the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_route_table_id" {
  description = "Identifier of the public route table"
  value       = aws_route_table.public.id
}

output "internet_gateway_id" {
  description = "Identifier of the attached Internet Gateway"
  value       = aws_internet_gateway.igw.id
}
