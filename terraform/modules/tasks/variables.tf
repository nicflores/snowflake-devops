variable "database_name" {
  type        = string
  description = "Name of the pre-existing database"
}

variable "warehouse_name" {
  type        = string
  description = "Name of the pre-existing warehouse (for task execution)"
}

variable "tasks" {
  type = map(object({
    schema        = string
    comment       = optional(string, "")
    schedule      = optional(string, null)
    after         = optional(string, null)
    enabled       = optional(bool, false)
    sql_statement = optional(string, "")
    sql_file      = optional(string, null)
  }))
  description = "Map of task definitions keyed by task name"
}
