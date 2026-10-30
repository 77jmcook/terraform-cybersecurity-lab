
terraform {
  required_version = ">= 1.0.0"
}

locals {
  project_name = "cybersecurity-lab"
  environment  = "development"
  security     = "enabled"
}

output "project_name" {
  value = local.project_name
}

output "environment" {
  value = local.environment
}

output "security_status" {
  value = local.security
}
