variable "database_name" {
  type        = string
  description = "Name of the pre-existing database"
}

variable "procedures" {
  type = map(object({
    schema      = string
    comment     = optional(string, "")
    return_type = string
    language    = string
    arguments = list(object({
      name = string
      type = string
    }))
    body                = optional(string, "")
    body_file           = optional(string, null)
    execute_as          = optional(string, "OWNER")
    null_input_behavior = optional(string, "CALLED ON NULL INPUT")
    runtime_version     = optional(string, null)
    snowpark_package    = optional(list(string), ["snowflake-snowpark-python"])
    packages            = optional(list(string), [])
    handler             = optional(string, null)
  }))
  description = "Map of procedure definitions keyed by procedure name"
}
