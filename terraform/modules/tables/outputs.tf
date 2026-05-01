output "schema_names" {
  description = "Map of schema keys (DATABASE__SCHEMA) to their Snowflake names"
  value       = { for k, v in snowflake_schema.this : k => v.name }
}

output "table_fqns" {
  description = "Map of table keys to fully qualified names (DB.SCHEMA.TABLE)"
  value = {
    for k, v in snowflake_table.this :
    k => "${v.database}.${v.schema}.${v.name}"
  }
}
