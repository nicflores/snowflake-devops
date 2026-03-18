# ---------------------------------------------------------------------------
# Warehouse
# ---------------------------------------------------------------------------
module "warehouse" {
  source = "../modules/warehouse"

  name           = local.warehouse_name
  environment    = var.environment
  warehouse_size = var.warehouse_size
}

# ---------------------------------------------------------------------------
# Database (shell only — schemas/tables managed by developer tier)
# ---------------------------------------------------------------------------
resource "snowflake_database" "this" {
  name    = local.database_name
  comment = "${local.database_name} — ${upper(var.environment)} environment"
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
# Roles & Grants (role creation, hierarchy, WH/DB level grants)
# ---------------------------------------------------------------------------
module "admin_roles" {
  source = "../modules/admin_roles"

  environment    = var.environment
  database_name  = snowflake_database.this.name
  warehouse_name = module.warehouse.name

  depends_on = [snowflake_database.this]
}
