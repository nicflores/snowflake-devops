variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "roles" {
  type        = map(any)
  description = "Map of role definitions from roles.yaml"
}

variable "warehouse_names" {
  type        = map(string)
  description = "Map of warehouse keys to their Snowflake names"
}

variable "database_names" {
  type        = map(string)
  description = "Map of database keys to their Snowflake names"
}
