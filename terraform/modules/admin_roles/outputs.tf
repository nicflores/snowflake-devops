output "loader_role_name" {
  description = "Name of the data loader role"
  value       = snowflake_account_role.loader.name
}

output "transformer_role_name" {
  description = "Name of the data transformer role"
  value       = snowflake_account_role.transformer.name
}

output "analyst_role_name" {
  description = "Name of the read-only analyst role"
  value       = snowflake_account_role.analyst.name
}
