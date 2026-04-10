output "warehouse_names" {
  value = { for k, v in module.warehouse : k => v.name }
}

output "database_names" {
  value = module.databases.database_names
}

output "storage_integration_name" {
  value = module.storage_integration.name
}

output "azure_consent_url" {
  description = "Visit this URL to grant Snowflake access to Azure storage"
  value       = module.storage_integration.azure_consent_url
}

output "azure_multi_tenant_app_name" {
  description = "Snowflake app name — assign Storage Blob Data Reader in Azure IAM"
  value       = module.storage_integration.azure_multi_tenant_app_name
}

output "role_names" {
  description = "Map of role keys to their Snowflake role names"
  value       = module.admin_roles.role_names
}
