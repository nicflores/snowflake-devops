output "warehouse_names" {
  value = { for k, v in module.warehouse : k => v.name }
}

output "database_names" {
  value = module.databases.database_names
}

output "database_bootstrap_account_roles" {
  description = "Account roles (ADMIN/DEPLOY) created per database"
  value       = { for k, v in module.database_bootstrap : k => v.account_roles }
}

output "database_bootstrap_global_database_roles" {
  description = "Global database roles (RO/RW/DDL) created per database"
  value       = { for k, v in module.database_bootstrap : k => v.global_database_roles }
}
