variable "database_name" {
  type        = string
  description = "Name of the pre-existing database"
}

variable "views" {
  type = map(object({
    schema    = string
    comment   = optional(string, "")
    is_secure = optional(bool, false)
    statement = string
  }))
  description = "Map of view definitions keyed by view name"
}
