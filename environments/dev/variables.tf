# environments/dev/variables.tf

variable "env" {
  type        = string
  description = "Target environment name"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.10.0.0/16"
}

variable "public_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets"
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
  default     = ["10.10.101.0/24", "10.10.102.0/24"]
}

variable "ingress_ports" {
  type        = list(number)
  description = "From and to ports for ingress security group rule"
  default     = [80, 80]
}

variable "ingress_cidrs" {
  type        = list(string)
  description = "Allowed ingress CIDRs"
  default     = ["0.0.0.0/0"]
}
