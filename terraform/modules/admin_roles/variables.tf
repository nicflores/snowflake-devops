variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "database_name" {
  type        = string
  description = "Name of the database to grant access to"
}

variable "warehouse_name" {
  type        = string
  description = "Name of the warehouse to grant usage on"
}

variable "cicd_role_name" {
  type        = string
  description = "Name of the CI/CD deploy role that needs ownership grants on the database"
  default     = "CICD_DEPLOY_ROLE"
}
