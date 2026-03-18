output "task_fqns" {
  description = "Map of task keys to fully qualified names (DB.SCHEMA.TASK)"
  value = merge(
    { for k, v in snowflake_task.root : k => "${v.database}.${v.schema}.${v.name}" },
    { for k, v in snowflake_task.child : k => "${v.database}.${v.schema}.${v.name}" }
  )
}
