# ---------------------------------------------------------------------------
# Snowflake Provider
# ---------------------------------------------------------------------------
variable "snowflake_user" {
  type        = string
  description = "Snowflake admin username"
}

variable "snowflake_private_key" {
  type        = string
  sensitive   = true
  description = "RSA private key in PEM format for key-pair authentication"
}

variable "snowflake_role" {
  type        = string
  description = "Snowflake role for admin operations"
  default     = "ACCOUNTADMIN"
}

# ---------------------------------------------------------------------------
# Azure
# ---------------------------------------------------------------------------
variable "azure_tenant_id" {
  type        = string
  description = "Azure AD tenant ID for the Snowflake storage integration"
}

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "warehouse_size" {
  type        = string
  description = "Snowflake warehouse size for this environment"
}
