# ---------------------------------------------------------------------------
# Warehouses (config-driven from admin/warehouses.yaml)
# ---------------------------------------------------------------------------
module "warehouse" {
  source   = "../modules/warehouse"
  for_each = local.warehouses

  name           = upper("${var.environment}_${upper(each.key)}_WH")
  environment    = var.environment
  warehouse_size = var.warehouse_size
}

# ---------------------------------------------------------------------------
# Databases (config-driven from admin/databases.yaml)
# ---------------------------------------------------------------------------
module "databases" {
  source = "../modules/databases"

  environment = var.environment
  databases   = local.databases
}

# ---------------------------------------------------------------------------
# Storage Integration
# ---------------------------------------------------------------------------
module "storage_integration" {
  source = "../modules/storage_integration"

  environment               = var.environment
  azure_tenant_id           = var.azure_tenant_id
  storage_allowed_locations = local.storage_allowed_locations
}

# Grant USAGE on the storage integration to the CI/CD role
resource "snowflake_grant_privileges_to_account_role" "cicd_integration" {
  account_role_name = "CICD_DEPLOY_ROLE"
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "INTEGRATION"
    object_name = module.storage_integration.name
  }
}

# ---------------------------------------------------------------------------
# Roles & Grants (config-driven from admin/roles.yaml)
# ---------------------------------------------------------------------------
module "admin_roles" {
  source = "../modules/admin_roles"

  environment     = var.environment
  roles           = local.roles
  warehouse_names = { for k, v in module.warehouse : k => v.name }
  database_names  = module.databases.database_names

  depends_on = [module.databases, module.warehouse]
}
