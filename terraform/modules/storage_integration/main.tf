resource "snowflake_storage_integration_azure" "this" {
  name    = upper("AZURE_${var.environment}_INTEGRATION")
  enabled = true

  azure_tenant_id           = var.azure_tenant_id
  storage_allowed_locations = var.storage_allowed_locations
}
