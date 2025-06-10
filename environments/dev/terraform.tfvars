# terraform.tfvars
env = "dev"
vpc_cidr = "10.10.0.0/16"
public_cidrs = ["10.10.1.0/24","10.10.2.0/24"]
private_cidrs = ["10.10.101.0/24","10.10.102.0/24"]
ingress_ports=[80,80]
ingress_cidrs=["0.0.0.0/0"]