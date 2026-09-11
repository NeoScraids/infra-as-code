# modules/subnet/variables.tf

variable "env" {
  type        = string
  description = "Target deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "Identifier of the VPC where subnets will reside"
}

variable "public_route_table_id" {
  type        = string
  description = "Identifier of the public route table for Internet Gateway association"
}

variable "public_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
  default     = []
}

variable "private_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = []
}
