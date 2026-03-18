variable "database_name" {
  type        = string
  description = "Name of the pre-existing database"
}

variable "functions" {
  type = map(object({
    schema      = string
    comment     = optional(string, "")
    return_type = string
    language    = string
    arguments = list(object({
      name = string
      type = string
    }))
    body            = optional(string, "")
    body_file       = optional(string, null)
    runtime_version = optional(string, null)
    packages        = optional(list(string), [])
    handler         = optional(string, null)
  }))
  description = "Map of function definitions keyed by function name"
}
