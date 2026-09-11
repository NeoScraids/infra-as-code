# modules/security-group/variables.tf

variable "env" {
  type        = string
  description = "Target deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group is created"
}

variable "ingress_ports" {
  type        = list(number)
  description = "Tuple defining [from_port, to_port] for TCP ingress"
  default     = [80, 80]
}

variable "ingress_cidrs" {
  type        = list(string)
  description = "Authorized CIDR blocks allowed for ingress"
  default     = ["0.0.0.0/0"]
}
