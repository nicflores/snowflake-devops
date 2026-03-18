variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "database_name" {
  type        = string
  description = "Name of the Snowflake database (pre-created by admin)"
}

variable "storage_integration_name" {
  type        = string
  description = "Name of the pre-existing storage integration (created by admin)"
}

variable "storage_sources" {
  type = map(object({
    schema               = string
    storage_account_name = string
    container_name       = string
    path_prefix          = string
    file_format = object({
      type                         = string
      skip_header                  = optional(number, 0)
      field_delimiter              = optional(string, ",")
      field_optionally_enclosed_by = optional(string, "\"")
      null_if                      = optional(list(string), [])
    })
  }))
  description = "Map of storage source definitions"
}

variable "tables" {
  type = map(object({
    schema  = string
    source  = optional(string, "")
    comment = optional(string, "")
    columns = list(object({
      name     = string
      type     = string
      nullable = optional(bool, true)
    }))
  }))
  description = "Map of table definitions (used to create pipes for tables with a source)"
}
