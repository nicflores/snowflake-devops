# ---------------------------------------------------------------------------
# Computed values used across admin modules
# ---------------------------------------------------------------------------
locals {
  # Admin configuration from YAML
  databases       = try(yamldecode(file("${path.module}/../config/admin/databases.yaml")), {})
  warehouses      = try(yamldecode(file("${path.module}/../config/admin/warehouses.yaml")), {})
  storage_sources = try(yamldecode(file("${path.module}/../config/admin/storage_sources.yaml")), {})
  roles           = try(yamldecode(file("${path.module}/../config/admin/roles.yaml")), {})

  # Derive Azure blob container URLs for the storage integration
  storage_allowed_locations = distinct([
    for key, src in local.storage_sources :
    "azure://${src.storage_account_name}.blob.core.windows.net/${src.container_name}/"
  ])
}
