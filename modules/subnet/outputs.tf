# modules/subnet/outputs.tf

output "public_subnet_ids" {
  description = "List of IDs for created public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "List of IDs for created private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnets_map" {
  description = "Map of public subnet identifiers to CIDRs"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnets_map" {
  description = "Map of private subnet identifiers to CIDRs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}
