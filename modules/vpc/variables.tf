# modules/vpc/variables.tf

variable "env" {
  type        = string
  description = "Target deployment environment (e.g., dev, staging, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}
