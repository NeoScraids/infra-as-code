# backend.tf
terraform { backend "s3" { bucket="bucket-dev" key="infra/dev/terraform.tfstate" region="us-east-1" dynamodb_table="lock-table-dev" encrypt=true }}