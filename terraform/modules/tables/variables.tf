variable "tables" {
  type = map(object({
    database      = optional(string, "")
    database_name = string
    schema        = string
    source        = optional(string, "")
    comment       = optional(string, "")
    columns = list(object({
      name     = string
      type     = string
      nullable = optional(bool, true)
    }))
  }))
  description = "Map of table definitions keyed by table name"
}
