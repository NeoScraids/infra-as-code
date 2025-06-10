# main.tf
module "vpc" { source="../../modules/vpc" env=var.env vpc_cidr=var.vpc_cidr }
module "subnet" { source="../../modules/subnet" env=var.env vpc_id=module.vpc.vpc_id public_cidrs=var.public_cidrs private_cidrs=var.private_cidrs }
module "sg" { source="../../modules/security-group" env=var.env vpc_id=module.vpc.vpc_id ingress_ports=var.ingress_ports ingress_cidrs=var.ingress_cidrs }