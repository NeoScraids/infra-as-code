# infra-as-code

> Módulos Terraform para desplegar infraestructuras AWS: VPC, subnets públicas/privadas y grupos de seguridad, con entornos `dev` y `prod`.

```
infra-as-code/
├── .gitignore
├── LICENSE
├── README.md
├── versions.tf
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── subnet/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── security-group/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── dev/
    │   ├── backend.tf
    │   ├── terraform.tfvars
    │   └── main.tf
    └── prod/
        ├── backend.tf
        ├── terraform.tfvars
        └── main.tf
```

---

## .gitignore
```gitignore
# Terraform state
*.tfstate
*.tfstate.backup
# Local Terraform directories
**/.terraform/
# Crash logs
crash.log
# CLI config
.terraformrc
``` 

---

## LICENSE (MIT)
```text
MIT License

Copyright (c) 2025 NeoScraids

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
``` 

---

## README.md
```markdown
# infra-as-code

> Módulos Terraform para desplegar infraestructuras AWS con buenas prácticas.

## Estructura
Ver el árbol de archivos arriba. Los módulos reutilizables están en `/modules` y los entornos en `/environments`.

## Requisitos
- Terraform >= 1.0.0
- Proveedor AWS (~> 4.0)
- AWS CLI configurado con credenciales

## Módulos
1. **vpc**: crea VPC, gateways y tablas rutas.
2. **subnet**: crea subredes públicas y privadas.
3. **security-group**: configura reglas de entrada y salida.

## Entornos
- **dev**: backend en S3 `bucket-dev` y lock en DynamoDB `lock-table-dev`.
- **prod**: backend en S3 `bucket-prod` y lock en DynamoDB `lock-table-prod`.

## Uso
```bash
git clone https://github.com/NeoScraids/infra-as-code.git
cd infra-as-code/environments/dev
terraform init
terraform apply
```

## Variables
Cada módulo y entorno define sus propias variables en `variables.tf` y `terraform.tfvars`.
```bash
# ejemplo en environments/dev/terraform.tfvars
env         = "dev"
vpc_cidr    = "10.10.0.0/16"
public_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
private_cidrs = ["10.10.101.0/24", "10.10.102.0/24"]
``` 

---

## versions.tf
```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
``` 

---

## modules/vpc/main.tf
```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "${var.env}-public-rt" }
}
``` 

## modules/vpc/variables.tf
```hcl
variable "env" {
  description = "Entorno (dev/prod)"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
}
``` 

## modules/vpc/outputs.tf
```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}
output "public_route_table_id" {
  value = aws_route_table.public.id
}
``` 

---

## modules/subnet/main.tf
```hcl
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_cidrs : idx => cidr }
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  map_public_ip_on_launch = true
  tags = { Name = "${var.env}-public-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_cidrs : idx => cidr }
  vpc_id     = var.vpc_id
  cidr_block = each.value
  tags = { Name = "${var.env}-private-${each.key}" }
}
``` 

## modules/subnet/variables.tf
```hcl
variable "env" {
  description = "Entorno (dev/prod)"
  type        = string
}
variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}
variable "public_cidrs" {
  description = "Lista de CIDRs públicos"
  type        = list(string)
}
variable "private_cidrs" {
  description = "Lista de CIDRs privados"
  type        = list(string)
}
``` 

## modules/subnet/outputs.tf
```hcl
output "public_subnet_ids" {
  value = values(aws_subnet.public)[*].id
}
output "private_subnet_ids" {
  value = values(aws_subnet.private)[*].id
}
``` 

---

## modules/security-group/main.tf
```hcl
resource "aws_security_group" "this" {
  name        = "${var.env}-sg"
  description = "Security group for ${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.ingress_ports[0]
    to_port     = var.ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env}-sg" }
}
``` 

## modules/security-group/variables.tf
```hcl
variable "env" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "ingress_ports" {
  description = "Rango de puertos TCP entrantes (e.g. [80, 80])"
  type        = list(number)
}
variable "ingress_cidrs" {
  description = "CIDRs permitidos"
  type        = list(string)
}
``` 

## modules/security-group/outputs.tf
```hcl
output "security_group_id" {
  value = aws_security_group.this.id
}
``` 

---

## environments/dev/backend.tf
```hcl
terraform {
  backend "s3" {
    bucket         = "bucket-dev"
    key            = "infra/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lock-table-dev"
    encrypt        = true
  }
}
``` 

## environments/dev/terraform.tfvars
```hcl
env           = "dev"
vpc_cidr      = "10.10.0.0/16"
public_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_cidrs = ["10.10.101.0/24", "10.10.102.0/24"]
ingress_ports = [80, 80]
ingress_cidrs = ["0.0.0.0/0"]
``` 

## environments/dev/main.tf
```hcl
module "vpc" {
  source    = "../../modules/vpc"
  env       = var.env
  vpc_cidr  = var.vpc_cidr
}

module "subnet" {
  source       = "../../modules/subnet"
  env          = var.env
  vpc_id       = module.vpc.vpc_id
  public_cidrs = var.public_cidrs
  private_cidrs = var.private_cidrs
}

module "sg" {
  source        = "../../modules/security-group"
  env           = var.env
  vpc_id        = module.vpc.vpc_id
  ingress_ports = var.ingress_ports
  ingress_cidrs = var.ingress_cidrs
}
``` 

---

## environments/prod/backend.tf
```hcl
terraform {
  backend "s3" {
    bucket         = "bucket-prod"
    key            = "infra/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lock-table-prod"
    encrypt        = true
  }
}
``` 

## environments/prod/terraform.tfvars
```hcl
env           = "prod"
vpc_cidr      = "10.20.0.0/16"
public_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_cidrs = ["10.20.101.0/24", "10.20.102.0/24"]
ingress_ports = [80, 443]
ingress_cidrs = ["0.0.0.0/0"]
``` 

## environments/prod/main.tf
```hcl
module "vpc" {
  source    = "../../modules/vpc"
  env       = var.env
  vpc_cidr  = var.vpc_cidr
}

module "subnet" {
  source       = "../../modules/subnet"
  env          = var.env
  vpc_id       = module.vpc.vpc_id
  public_cidrs = var.public_cidrs
  private_cidrs = var.private_cidrs
}

module "sg" {
  source        = "../../modules/security-group"
  env           = var.env
  vpc_id        = module.vpc.vpc_id
  ingress_ports = var.ingress_ports
  ingress_cidrs = var.ingress_cidrs
}
```
