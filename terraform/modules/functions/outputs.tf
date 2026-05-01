output "function_fqns" {
  description = "Map of function keys to fully qualified names (DB.SCHEMA.FUNCTION)"
  value = merge(
    { for k, v in snowflake_function_sql.this : k => "${v.database}.${v.schema}.${v.name}" },
    { for k, v in snowflake_function_python.this : k => "${v.database}.${v.schema}.${v.name}" }
  )
}
