# environments/dev/outputs.tf

output "vpc_id" {
  description = "Identifier of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet identifiers"
  value       = module.subnet.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet identifiers"
  value       = module.subnet.private_subnet_ids
}

output "security_group_id" {
  description = "Identifier of the application security group"
  value       = module.security_group.security_group_id
}
