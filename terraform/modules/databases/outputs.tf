output "database_names" {
  description = "Map of database keys to their Snowflake names"
  value       = { for k, v in snowflake_database.this : k => v.name }
}
