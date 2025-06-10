# infra-as-code

> Conjunto de módulos Terraform diseñado para implementar infraestructura en AWS de forma modular y profesional, siguiendo mejores prácticas de IaC (Infraestructura como Código).

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

## Descripción General
Este repositorio contiene:
- **Módulos reutilizables** bajo `modules/`, cada uno encapsula recursos específicos (VPC, subnets, security groups).
- **Entornos** (`dev` y `prod`) bajo `environments/`, que configuran backends remotos y variables propias.
- Configuración de versiones y proveedores en `versions.tf`.
- Documentación y licenciamiento.

El objetivo es permitir despliegues consistentes y repetibles, facilitando:
- Separación clara entre lógica de infraestructura (módulos) y configuración de entornos.
- Control de versiones de Terraform y proveedores.
- Bloqueo de estado remoto con S3 y DynamoDB.

---

## Archivos Clave

### 1. versions.tf
Define la versión mínima de Terraform y del proveedor AWS:

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

### 2. .gitignore
Ignora estados locales y archivos sensibles:

```gitignore
# Estados de Terraform
environments/**/.terraform/
*.tfstate
*.tfstate.backup
# Logs de errores
crash.log
# Configuración CLI
.terraformrc
```  

### 3. LICENSE
Licencia MIT para uso libre y contribuciones abiertas.

---

## Módulos
Cada módulo sigue la estructura:
```
modules/<nombre>/
├── main.tf      # Recursos
├── variables.tf # Parámetros de entrada
└── outputs.tf   # Valores exportados
```

#### 3.1 Módulo VPC
- **main.tf**: crea VPC, Internet Gateway y tabla de rutas públicas.
- **variables.tf**: define `env` (dev/prod) y `vpc_cidr`.
- **outputs.tf**: expone `vpc_id` y `public_route_table_id`.

```hcl
# modules/vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "${var.env}-vpc" }
}
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.env}-igw" }
}
# Tabla de rutas públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route { cidr_block = "0.0.0.0/0" gateway_id = aws_internet_gateway.igw.id }
  tags = { Name = "${var.env}-public-rt" }
}
```  

#### 3.2 Módulo Subnet
- **main.tf**: genera subnets públicas y privadas en función de listas de CIDR.
- **variables.tf**: parámetros `env`, `vpc_id`, `public_cidrs`, `private_cidrs`.
- **outputs.tf**: expone IDs de subnets.

```hcl
# modules/subnet/main.tf
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_cidrs : idx => cidr }
  vpc_id                   = var.vpc_id
  cidr_block               = each.value
  map_public_ip_on_launch  = true
  tags = { Name = "${var.env}-public-${each.key}" }
}
# Privadas
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_cidrs : idx => cidr }
  vpc_id     = var.vpc_id
  cidr_block = each.value
  tags = { Name = "${var.env}-private-${each.key}" }
}
```  

#### 3.3 Módulo Security Group
- **main.tf**: define reglas de entrada (ingress) y salida (egress).
- **variables.tf**: `env`, `vpc_id`, `ingress_ports`, `ingress_cidrs`.
- **outputs.tf**: exporta `security_group_id`.

```hcl
# modules/security-group/main.tf
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
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
  tags = { Name = "${var.env}-sg" }
}
```  

---

## Entornos
Cada entorno configura su backend remoto y llama a los módulos:
```
environments/<entorno>/
├── backend.tf       # Configura S3 + DynamoDB para el estado remoto
├── terraform.tfvars # Valores de variables para <entorno>
└── main.tf          # Invocaciones de módulos
```

### 4.1 Entorno DEV
```hcl
# backend.tf
terraform { backend "s3" { bucket="bucket-dev" key="infra/dev/terraform.tfstate" region="us-east-1" dynamodb_table="lock-table-dev" encrypt=true }}
```
```hcl
# terraform.tfvars
env = "dev"
vpc_cidr = "10.10.0.0/16"
public_cidrs = ["10.10.1.0/24","10.10.2.0/24"]
private_cidrs = ["10.10.101.0/24","10.10.102.0/24"]
ingress_ports=[80,80]
ingress_cidrs=["0.0.0.0/0"]
```
```hcl
# main.tf
module "vpc" { source="../../modules/vpc" env=var.env vpc_cidr=var.vpc_cidr }
module "subnet" { source="../../modules/subnet" env=var.env vpc_id=module.vpc.vpc_id public_cidrs=var.public_cidrs private_cidrs=var.private_cidrs }
module "sg" { source="../../modules/security-group" env=var.env vpc_id=module.vpc.vpc_id ingress_ports=var.ingress_ports ingress_cidrs=var.ingress_cidrs }
```

### 4.2 Entorno PROD
Mismos archivos que DEV, cambiando backends y variables:
- **bucket-prod**, **lock-table-prod**
- CIDRs en rango `10.20.x.x`

---

## Flujo de Trabajo
1. **Init**: `terraform init` configura backend y descarga proveedores.
2. **Plan**: `terraform plan` muestra cambios propuestos.
3. **Apply**: `terraform apply -auto-approve` implementa recursos.
4. **Destroy**: `terraform destroy` limpia todo.

Recomendaciones:
- Versiona tu código en Git y revisa cambios con PRs.
- Usa Terraform Cloud o Atlantis para automatizar plans/applies.
- Mantén tus módulos independientes y probados con `terraform validate` y `terraform fmt`.

---

## Autor y Contribuciones
NeosCraids — [GitHub](https://github.com/NeoScraids)

Este proyecto está bajo licencia MIT; ¡contribuciones bienvenidas!
