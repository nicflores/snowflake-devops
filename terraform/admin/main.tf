# ---------------------------------------------------------------------------
# Warehouses (one per database, defined in databases.yaml)
# ---------------------------------------------------------------------------
module "warehouse" {
  source   = "../modules/warehouse"
  for_each = local.warehouses

  name              = upper("${var.env_prefix}_${lookup(each.value, "name", "${upper(each.key)}_WH")}")
  warehouse_size    = lookup(each.value, "warehouse_size", var.warehouse_size)
  warehouse_type    = lookup(each.value, "warehouse_type", "STANDARD")
  auto_suspend      = lookup(each.value, "auto_suspend", 60)
  auto_resume       = tostring(lookup(each.value, "auto_resume", true))
  min_cluster_count = lookup(each.value, "min_cluster_count", 1)
  max_cluster_count = lookup(each.value, "max_cluster_count", 1)
  scaling_policy    = lookup(each.value, "scaling_policy", "STANDARD")
  comment           = lookup(each.value, "comment", null)
}

# ---------------------------------------------------------------------------
# Databases
# ---------------------------------------------------------------------------
module "databases" {
  source = "../modules/databases"

  environment = var.environment
  env_prefix  = var.env_prefix
  databases   = local.databases
}

# ---------------------------------------------------------------------------
# Security bootstrap — account roles, schemas, and database role hierarchy
# Applied to every database, matching the pattern in snowflake_admin.sql
# ---------------------------------------------------------------------------
module "database_bootstrap" {
  source   = "../modules/database_bootstrap"
  for_each = local.databases

  database_name         = module.databases.database_names[each.key]
  role_prefix           = lookup(each.value, "role_prefix", null) != null ? upper("${var.env_prefix}_${each.value.role_prefix}") : upper(module.databases.database_names[each.key])
  app_admin_parent_role = lookup(each.value, "app_admin_parent_role", "SYSADMIN")
  cicd_role_name        = lookup(each.value, "cicd_role_name", "CICD_DEPLOY_ROLE")
  warehouse_name        = module.warehouse[each.key].name
  schemas               = [for s in lookup(each.value, "schemas", ["RAW", "UTIL", "AUDIT", "CDC", "CURATED"]) : upper(s)]

  depends_on = [module.databases, module.warehouse]
}
