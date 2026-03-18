output "function_fqns" {
  description = "Map of function keys to fully qualified names (DB.SCHEMA.FUNCTION)"
  value = {
    for k, v in snowflake_function.this :
    k => "${v.database}.${v.schema}.${v.name}"
  }
}
