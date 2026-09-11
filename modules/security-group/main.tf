# modules/security-group/main.tf

resource "aws_security_group" "this" {
  name        = "${var.env}-sg"
  description = "Application security group for ${var.env} environment"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress traffic rule"
    from_port   = var.ingress_ports[0]
    to_port     = var.ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-sg"
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}