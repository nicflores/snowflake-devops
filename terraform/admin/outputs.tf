output "warehouse_name" {
  value = module.warehouse.name
}

output "database_name" {
  value = snowflake_database.this.name
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

output "loader_role" {
  value = module.admin_roles.loader_role_name
}

output "transformer_role" {
  value = module.admin_roles.transformer_role_name
}

output "analyst_role" {
  value = module.admin_roles.analyst_role_name
}
