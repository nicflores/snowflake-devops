variable "tasks" {
  type = map(object({
    database       = optional(string, "")
    database_name  = string
    warehouse      = optional(string, "")
    warehouse_name = string
    schema         = string
    comment        = optional(string, "")
    schedule = optional(object({
      minutes    = optional(number, null)
      hours      = optional(number, null)
      using_cron = optional(string, null)
    }), null)
    after         = optional(string, null)
    started       = optional(bool, false)
    sql_statement = optional(string, "")
    sql_file      = optional(string, null)
  }))
  description = "Map of task definitions keyed by task name"
}
