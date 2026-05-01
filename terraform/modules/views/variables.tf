variable "views" {
  type = map(object({
    database      = optional(string, "")
    database_name = string
    schema        = string
    comment       = optional(string, "")
    is_secure     = optional(string, "false")
    statement     = string
  }))
  description = "Map of view definitions keyed by view name"
}
