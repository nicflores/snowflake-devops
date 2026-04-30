locals {
  prefix = upper(var.role_prefix)

  schema_set = toset([for s in var.schemas : upper(s)])

  # Global database roles, matching the SQL pattern: <PREFIX>_RO/RW/DDL
  global_role_names = {
    ro  = "${local.prefix}_RO"
    rw  = "${local.prefix}_RW"
    ddl = "${local.prefix}_DDL"
  }

  # Per-schema database roles, matching SQL pattern: <PREFIX>_<SCHEMA>_RO/RW/DDL
  schema_role_defs = {
    for pair in flatten([
      for s in local.schema_set : [
        { key = "${lower(s)}-ro", schema = s, tier = "RO", name = "${local.prefix}_${s}_RO" },
        { key = "${lower(s)}-rw", schema = s, tier = "RW", name = "${local.prefix}_${s}_RW" },
        { key = "${lower(s)}-ddl", schema = s, tier = "DDL", name = "${local.prefix}_${s}_DDL" }
      ]
    ]) : pair.key => pair
  }

  schema_fqns = {
    for s, v in snowflake_schema.this : s => format("\"%s\".\"%s\"", var.database_name, v.name)
  }

  schema_roles = {
    for s in local.schema_set : s => {
      ro  = snowflake_database_role.schema["${lower(s)}-ro"].fully_qualified_name
      rw  = snowflake_database_role.schema["${lower(s)}-rw"].fully_qualified_name
      ddl = snowflake_database_role.schema["${lower(s)}-ddl"].fully_qualified_name
    }
  }

  # Per-schema privilege maps for database role grants
  ro_all_object_grants = {
    for pair in flatten([
      for s in local.schema_set : [
        { key = "${lower(s)}-tables", schema = s, role = local.schema_roles[s].ro, object_type = "TABLES" },
        { key = "${lower(s)}-views", schema = s, role = local.schema_roles[s].ro, object_type = "VIEWS" }
      ]
    ]) : pair.key => pair
  }

  ro_future_object_grants = local.ro_all_object_grants

  rw_all_table_grants = {
    for s in local.schema_set : lower(s) => {
      role = local.schema_roles[s].rw
    }
  }

  rw_future_table_grants = local.rw_all_table_grants

  ddl_schema_grants = {
    for s in local.schema_set : lower(s) => {
      role       = local.schema_roles[s].ddl
      schema_fqn = local.schema_fqns[s]
    }
  }
}

# ---------------------------------------------------------------------------
# Account Roles (<PREFIX>_ADMIN / <PREFIX>_DEPLOY)
# ---------------------------------------------------------------------------
resource "snowflake_account_role" "admin" {
  name    = "${local.prefix}_ADMIN"
  comment = "Admin role for ${local.prefix} database"
}

resource "snowflake_account_role" "deploy" {
  name    = "${local.prefix}_DEPLOY"
  comment = "Deployment role for ${local.prefix} database"
}

# SQL equivalent:
# GRANT ROLE <PREFIX>_DEPLOY TO ROLE <PREFIX>_ADMIN;
resource "snowflake_grant_account_role" "deploy_to_admin" {
  role_name        = snowflake_account_role.deploy.name
  parent_role_name = snowflake_account_role.admin.name
}

# SQL equivalent:
# GRANT ROLE <PREFIX>_ADMIN TO ROLE <APP_ADMIN_PARENT_ROLE>;
resource "snowflake_grant_account_role" "admin_to_enterprise_appadmin" {
  role_name        = snowflake_account_role.admin.name
  parent_role_name = var.app_admin_parent_role
}

# SQL equivalent:
# GRANT ROLE <PREFIX>_DEPLOY TO ROLE <CICD_ROLE_NAME>;
resource "snowflake_grant_account_role" "deploy_to_cicd" {
  role_name        = snowflake_account_role.deploy.name
  parent_role_name = var.cicd_role_name
}

# Warehouse grants in SQL:
# GRANT USAGE, MONITOR ON WAREHOUSE <WH> TO ROLE <PREFIX>_ADMIN/<PREFIX>_DEPLOY;
resource "snowflake_grant_privileges_to_account_role" "warehouse_usage" {
  for_each = {
    admin  = snowflake_account_role.admin.name
    deploy = snowflake_account_role.deploy.name
  }

  account_role_name = each.value
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "warehouse_monitor" {
  for_each = {
    admin  = snowflake_account_role.admin.name
    deploy = snowflake_account_role.deploy.name
  }

  account_role_name = each.value
  privileges        = ["MONITOR"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

# SQL equivalent:
# GRANT OWNERSHIP ON DATABASE <DB> TO ROLE <PREFIX>_DEPLOY COPY CURRENT GRANTS;
resource "snowflake_grant_ownership" "database_to_deploy" {
  account_role_name   = snowflake_account_role.deploy.name
  outbound_privileges = "COPY"

  on {
    object_type = "DATABASE"
    object_name = var.database_name
  }
}

# ---------------------------------------------------------------------------
# Managed-access schemas
# ---------------------------------------------------------------------------
resource "snowflake_schema" "this" {
  for_each = local.schema_set

  database            = var.database_name
  name                = each.key
  with_managed_access = "true"
}

# SQL equivalent:
# GRANT OWNERSHIP ON ALL SCHEMAS IN DATABASE <DB> TO ROLE <PREFIX>_DEPLOY;
resource "snowflake_grant_ownership" "all_schemas_to_deploy" {
  account_role_name = snowflake_account_role.deploy.name

  on {
    all {
      object_type_plural = "SCHEMAS"
      in_database        = var.database_name
    }
  }

  depends_on = [snowflake_schema.this]
}

# ---------------------------------------------------------------------------
# Global database roles (<PREFIX>_RO/RW/DDL)
# ---------------------------------------------------------------------------
resource "snowflake_database_role" "global_ro" {
  database = var.database_name
  name     = local.global_role_names.ro
}

resource "snowflake_database_role" "global_rw" {
  database = var.database_name
  name     = local.global_role_names.rw
}

resource "snowflake_database_role" "global_ddl" {
  database = var.database_name
  name     = local.global_role_names.ddl
}

# ---------------------------------------------------------------------------
# Per-schema database roles (<PREFIX>_<SCHEMA>_RO/RW/DDL)
# ---------------------------------------------------------------------------
resource "snowflake_database_role" "schema" {
  for_each = local.schema_role_defs

  database = var.database_name
  name     = each.value.name
}

# SQL equivalent per schema:
# GRANT DATABASE ROLE <PREFIX>_<SCHEMA>_RO TO DATABASE ROLE <PREFIX>_<SCHEMA>_RW;
# GRANT DATABASE ROLE <PREFIX>_<SCHEMA>_RW TO DATABASE ROLE <PREFIX>_<SCHEMA>_DDL;
resource "snowflake_grant_database_role" "schema_ro_to_rw" {
  for_each = local.schema_set

  database_role_name        = local.schema_roles[each.key].ro
  parent_database_role_name = local.schema_roles[each.key].rw
}

resource "snowflake_grant_database_role" "schema_rw_to_ddl" {
  for_each = local.schema_set

  database_role_name        = local.schema_roles[each.key].rw
  parent_database_role_name = local.schema_roles[each.key].ddl
}

# SQL equivalent per schema:
# GRANT DATABASE ROLE <PREFIX>_<SCHEMA>_RO TO DATABASE ROLE <PREFIX>_RO;
# GRANT DATABASE ROLE <PREFIX>_<SCHEMA>_RW TO DATABASE ROLE <PREFIX>_RW;
# GRANT DATABASE ROLE <PREFIX>_<SCHEMA>_DDL TO DATABASE ROLE <PREFIX>_DDL;
resource "snowflake_grant_database_role" "schema_to_global_ro" {
  for_each = local.schema_set

  database_role_name        = local.schema_roles[each.key].ro
  parent_database_role_name = snowflake_database_role.global_ro.fully_qualified_name
}

resource "snowflake_grant_database_role" "schema_to_global_rw" {
  for_each = local.schema_set

  database_role_name        = local.schema_roles[each.key].rw
  parent_database_role_name = snowflake_database_role.global_rw.fully_qualified_name
}

resource "snowflake_grant_database_role" "schema_to_global_ddl" {
  for_each = local.schema_set

  database_role_name        = local.schema_roles[each.key].ddl
  parent_database_role_name = snowflake_database_role.global_ddl.fully_qualified_name
}

# SQL equivalent:
# GRANT ROLE <PREFIX>_RO TO ROLE <CICD_ROLE_NAME>;
resource "snowflake_grant_database_role" "global_ro_to_cicd" {
  database_role_name = snowflake_database_role.global_ro.fully_qualified_name
  parent_role_name   = var.cicd_role_name
}

# ---------------------------------------------------------------------------
# Privileges per schema (SQL-equivalent RO/RW/DDL blocks)
# ---------------------------------------------------------------------------
# GRANT USAGE ON DATABASE <DB> TO DATABASE ROLE <PREFIX>_<SCHEMA>_RO;
resource "snowflake_grant_privileges_to_database_role" "schema_ro_database_usage" {
  for_each = local.schema_set

  database_role_name = local.schema_roles[each.key].ro
  privileges         = ["USAGE"]
  on_database        = var.database_name
}

# GRANT USAGE ON SCHEMA <DB>.<SCHEMA> TO DATABASE ROLE <PREFIX>_<SCHEMA>_RO;
resource "snowflake_grant_privileges_to_database_role" "schema_ro_schema_usage" {
  for_each = local.schema_set

  database_role_name = local.schema_roles[each.key].ro
  privileges         = ["USAGE"]
  on_schema {
    schema_name = local.schema_fqns[each.key]
  }
}

# RO: SELECT on all tables/views
resource "snowflake_grant_privileges_to_database_role" "schema_ro_all_objects" {
  for_each = local.ro_all_object_grants

  database_role_name = each.value.role
  privileges         = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = each.value.object_type
      in_schema          = local.schema_fqns[each.value.schema]
    }
  }
}

# RO: SELECT on future tables/views
resource "snowflake_grant_privileges_to_database_role" "schema_ro_future_objects" {
  for_each = local.ro_future_object_grants

  database_role_name = each.value.role
  privileges         = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = each.value.object_type
      in_schema          = local.schema_fqns[each.value.schema]
    }
  }
}

# RW: DML on all/future tables
resource "snowflake_grant_privileges_to_database_role" "schema_rw_all_tables" {
  for_each = local.rw_all_table_grants

  database_role_name = each.value.role
  privileges         = ["INSERT", "DELETE", "TRUNCATE", "UPDATE", "REFERENCES"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = local.schema_fqns[upper(each.key)]
    }
  }
}

resource "snowflake_grant_privileges_to_database_role" "schema_rw_future_tables" {
  for_each = local.rw_future_table_grants

  database_role_name = each.value.role
  privileges         = ["INSERT", "DELETE", "TRUNCATE", "UPDATE", "REFERENCES"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = local.schema_fqns[upper(each.key)]
    }
  }
}

# DDL: create privileges on schema
resource "snowflake_grant_privileges_to_database_role" "schema_ddl_create_set_1" {
  for_each = local.ddl_schema_grants

  database_role_name = each.value.role
  privileges = [
    "CREATE TABLE",
    "CREATE VIEW",
    "CREATE PROCEDURE",
    "CREATE EXTERNAL TABLE",
    "CREATE SEQUENCE",
    "CREATE FUNCTION"
  ]

  on_schema {
    schema_name = each.value.schema_fqn
  }
}

resource "snowflake_grant_privileges_to_database_role" "schema_ddl_create_set_2" {
  for_each = local.ddl_schema_grants

  database_role_name = each.value.role
  privileges = [
    "CREATE MATERIALIZED VIEW",
    "CREATE FILE FORMAT",
    "CREATE STAGE",
    "CREATE PIPE",
    "CREATE STREAM",
    "CREATE TASK"
  ]

  on_schema {
    schema_name = each.value.schema_fqn
  }
}
