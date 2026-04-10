output "role_names" {
  description = "Map of role keys to their resolved Snowflake role names"
  value       = local.role_name_map
}
