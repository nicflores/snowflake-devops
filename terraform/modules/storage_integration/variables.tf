variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure AD tenant ID for the storage integration"
}

variable "storage_allowed_locations" {
  type        = list(string)
  description = "List of Azure blob container URLs that Snowflake is allowed to access"
}
