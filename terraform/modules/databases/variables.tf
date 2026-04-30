variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "env_prefix" {
  type        = string
  description = "Single-character environment prefix prepended to all names (e.g. D for DEV, P for PROD)"
}

variable "databases" {
  type        = any
  description = "Map of database definitions from databases.yaml"
}
