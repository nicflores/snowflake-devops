# ---------------------------------------------------------------------------
# Computed values used across developer-tier modules
# ---------------------------------------------------------------------------
locals {
  name_prefix = "BACKOFFICE"

  # Must match the naming convention in admin/locals.tf
  database_name            = upper("${var.environment}_${local.name_prefix}_DB")
  storage_integration_name = upper("AZURE_${var.environment}_INTEGRATION")

  # Role names — must match what admin tier creates
  loader_role_name      = upper("${var.environment}_LOADER")
  transformer_role_name = upper("${var.environment}_TRANSFORMER")
  analyst_role_name     = upper("${var.environment}_ANALYST")

  # Shared configuration from YAML
  tables          = yamldecode(file("${path.module}/../config/tables.yaml"))
  storage_sources = yamldecode(file("${path.module}/../config/storage_sources.yaml"))
}
