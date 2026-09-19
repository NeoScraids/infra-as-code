# modules/vpc/variables.tf

variable "env" {
  type        = string
  description = "Target deployment environment (e.g., dev, staging, prod)"
}

variable "project" {
  type        = string
  description = "Project name used for cost allocation tags in AWS Cost Explorer"
  default     = "default"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Whether to enable DNS hostnames in the VPC. Disable only if the workload has a specific reason to avoid DNS-resolved instance names."
  default     = true
}
