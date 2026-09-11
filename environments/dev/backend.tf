# environments/dev/backend.tf

terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "bucket-dev"
    key            = "infra/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lock-table-dev"
    encrypt        = true
  }
}