output "name" {
  description = "Name of the storage integration"
  value       = snowflake_storage_integration.this.name
}

output "azure_consent_url" {
  description = "Visit this URL to grant Snowflake access to your Azure storage"
  value       = snowflake_storage_integration.this.azure_consent_url
}

output "azure_multi_tenant_app_name" {
  description = "Snowflake application name — assign Storage Blob Data Reader in Azure IAM"
  value       = snowflake_storage_integration.this.azure_multi_tenant_app_name
}
