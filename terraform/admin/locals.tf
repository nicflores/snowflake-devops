# ---------------------------------------------------------------------------
# Computed values used across admin modules
# ---------------------------------------------------------------------------
locals {
  # Single source of truth: databases.yaml defines every database and its warehouse
  config = try(tomap(yamldecode(file("${path.module}/config/databases.yaml"))), {})

  # Pass the full config to modules — extra keys (warehouse) are ignored by each module
  databases = local.config

  # Extract the warehouse block nested under each database entry
  warehouses = {
    for k, v in local.config : k => v.warehouse
    if lookup(v, "warehouse", null) != null
  }
}
