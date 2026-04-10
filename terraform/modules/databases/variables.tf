variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "databases" {
  type        = map(any)
  description = "Map of database definitions from databases.yaml"
}
