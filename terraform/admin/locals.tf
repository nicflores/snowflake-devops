# ---------------------------------------------------------------------------
# Computed values used across admin modules
# ---------------------------------------------------------------------------
locals {
  name_prefix = "BACKOFFICE"

  # Computed resource names — centralised naming convention
  database_name  = upper("${var.environment}_${local.name_prefix}_DB")
  warehouse_name = upper("${var.environment}_${local.name_prefix}_WH")

  # Shared configuration from YAML (for deriving allowed storage locations)
  storage_sources = yamldecode(file("${path.module}/../config/storage_sources.yaml"))

  # Derive Azure blob container URLs for the storage integration
  storage_allowed_locations = distinct([
    for key, src in local.storage_sources :
    "azure://${src.storage_account_name}.blob.core.windows.net/${src.container_name}/"
  ])
}
