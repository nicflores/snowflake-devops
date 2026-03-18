variable "database_name" {
  type        = string
  description = "Name of the pre-existing database (created by admin)"
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
  description = "Map of table definitions keyed by table name"
}
