resource "snowflake_storage_integration" "this" {
  name    = upper("AZURE_${var.environment}_INTEGRATION")
  type    = "EXTERNAL_STAGE"
  enabled = true

  storage_provider          = "AZURE"
  azure_tenant_id           = var.azure_tenant_id
  storage_allowed_locations = var.storage_allowed_locations
}
