variable "database_name" {
  type        = string
  description = "Target database name"
}

variable "role_prefix" {
  type        = string
  description = "Prefix used for account/database role names (example: D_CUSIP)"
}

variable "app_admin_parent_role" {
  type        = string
  description = "Existing enterprise app-admin account role that should inherit <prefix>_ADMIN"
}

variable "cicd_role_name" {
  type        = string
  description = "Existing CI/CD account role that should inherit <prefix>_DEPLOY and <prefix>_RO"
}

variable "warehouse_name" {
  type        = string
  description = "Warehouse to grant USAGE/MONITOR on for ADMIN and DEPLOY roles"
}

variable "schemas" {
  type        = list(string)
  description = "Managed-access schemas to create and secure"
}
