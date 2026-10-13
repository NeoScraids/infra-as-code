# infra-as-code

Terraform para armar una red base en AWS: una VPC con subnets publicas y privadas, internet gateway, tabla de rutas publica y un security group. Esta organizado en modulos y con un entorno `dev` que los usa.

Es una base para arrancar, no una arquitectura completa. Lo que no incluye:
- NAT: las subnets privadas no tienen salida a internet.
- Zonas de disponibilidad fijas: AWS elige la zona de cada subnet.
- Tabla de rutas propia para las privadas: usan la principal de la VPC.

## Como probarlo

Necesitas AWS CLI configurado y Terraform 1.0 o superior. El backend remoto usa un bucket S3 y una tabla DynamoDB que tienen que existir antes (`bucket-dev` y `lock-table-dev` en `environments/dev/backend.tf`, cambia los nombres por los tuyos).

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

`terraform.tfvars` se carga solo. Los valores por defecto son los mismos que ahi.

## Variables del entorno dev

| Variable | Default | Para que |
| :--- | :--- | :--- |
| `env` | `dev` | nombre del entorno, va en los nombres y tags |
| `project` | `infra-as-code` | tag `Project` de la VPC |
| `vpc_cidr` | `10.10.0.0/16` | rango de la VPC |
| `enable_dns_hostnames` | `true` | DNS hostnames dentro de la VPC |
| `public_cidrs` | `10.10.1.0/24`, `10.10.2.0/24` | subnets publicas |
| `private_cidrs` | `10.10.101.0/24`, `10.10.102.0/24` | subnets privadas |
| `ingress_ports` | `[80, 80]` | `[desde, hasta]` del puerto TCP abierto |
| `ingress_cidrs` | `["0.0.0.0/0"]` | quien puede entrar, restringelo si no es una prueba |

Outputs: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `security_group_id`.

## Estructura

```
environments/dev/   backend, versions, variables y uso de los modulos
modules/vpc/        VPC, internet gateway y tabla de rutas publica
modules/subnet/     subnets publicas y privadas
modules/security-group/
```

## Licencia

MIT
