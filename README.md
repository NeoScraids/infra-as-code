# infra-as-code

> Módulos Terraform para desplegar infraestructuras en AWS: VPC, subnets públicas y privadas, y seguridad.

```
infra-as-code/
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
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── .gitignore
├── README.md
└── versions.tf
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

## .gitignore
```gitignore
# Local .terraform directories
**/.terraform/
# Terraform state files
*.tfstate
*.tfstate.backup
# Crash log files
crash.log
# CLI configuration files
.terraformrc
terraform.rc
