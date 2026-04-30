# ---------------------------------------------------------------------------
# Snowflake Provider
# ---------------------------------------------------------------------------
variable "snowflake_user" {
  type        = string
  description = "Snowflake username for Terraform service account"
  default     = "SVC_CICD"
}

variable "snowflake_private_key" {
  type        = string
  sensitive   = true
  description = "RSA private key in PEM format for key-pair authentication"
}

variable "snowflake_role" {
  type        = string
  description = "Snowflake role used by Terraform"
  default     = "CICD_DEPLOY_ROLE"
}

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "env_prefix" {
  type        = string
  description = "Single-character prefix prepended to all Snowflake object names (e.g. D for DEV, P for PROD)"
}

variable "database_key" {
  type        = string
  description = "Key matching an entry in admin/config/databases.yaml (e.g. cusip)"
}
