# ---------------------------------------------------------------------------
# Locals — flatten YAML-driven role config into for_each-friendly maps
# ---------------------------------------------------------------------------
locals {
  # Roles to create (exclude pre-existing ones)
  roles_to_create = {
    for k, v in var.roles : k => v
    if lookup(v, "create", true)
  }

  # Resolved Snowflake role name for every role
  role_name_map = {
    for k, v in var.roles : k => (
      lookup(v, "create", true)
      ? upper("${var.environment}_${k}")
      : v.role_name
    )
  }

  # Roles that define a parent_role → hierarchy grants
  role_hierarchy = {
    for k, v in var.roles : k => v.parent_role
    if lookup(v, "parent_role", null) != null
  }

  # Flatten warehouse grants: { "loader-backoffice" => { ... } }
  warehouse_grants = {
    for pair in flatten([
      for role_key, role in var.roles : [
        for wh_key, privileges in lookup(role, "warehouses", {}) : {
          key        = "${role_key}-${wh_key}"
          role_name  = local.role_name_map[role_key]
          warehouse  = var.warehouse_names[wh_key]
          privileges = privileges
        }
      ]
    ]) : pair.key => pair
  }

  # Flatten database grants: { "loader-backoffice" => { ... } }
  database_grants = {
    for pair in flatten([
      for role_key, role in var.roles : [
        for db_key, privileges in lookup(role, "databases", {}) : {
          key        = "${role_key}-${db_key}"
          role_name  = local.role_name_map[role_key]
          database   = var.database_names[db_key]
          privileges = privileges
        }
      ]
    ]) : pair.key => pair
  }

  # Account-level privileges (e.g. EXECUTE TASK)
  account_grants = {
    for k, v in var.roles : k => {
      role_name  = local.role_name_map[k]
      privileges = v.account_privileges
    }
    if length(lookup(v, "account_privileges", [])) > 0
  }

  # Future grants — schemas (all_privileges on future schemas in database)
  future_schema_grants = {
    for pair in flatten([
      for role_key, role in var.roles : [
        for db_key, obj_types in lookup(role, "future_grants", {}) : {
          key       = "${role_key}-${db_key}"
          role_name = local.role_name_map[role_key]
          database  = var.database_names[db_key]
        } if contains(obj_types, "SCHEMAS")
      ]
    ]) : pair.key => pair
  }

  # Future grants — objects (all_privileges on future objects in database)
  future_object_grants = {
    for pair in flatten([
      for role_key, role in var.roles : [
        for db_key, obj_types in lookup(role, "future_grants", {}) : [
          for obj_type in obj_types : {
            key                = "${role_key}-${db_key}-${lower(replace(obj_type, " ", "-"))}"
            role_name          = local.role_name_map[role_key]
            database           = var.database_names[db_key]
            object_type_plural = obj_type
          } if obj_type != "SCHEMAS"
        ]
      ]
    ]) : pair.key => pair
  }
}

# ---------------------------------------------------------------------------
# Roles
# ---------------------------------------------------------------------------
resource "snowflake_account_role" "this" {
  for_each = local.roles_to_create

  name    = local.role_name_map[each.key]
  comment = "${each.value.comment} for ${upper(var.environment)}"
}

# ---------------------------------------------------------------------------
# Role Hierarchy
# ---------------------------------------------------------------------------
resource "snowflake_grant_account_role" "hierarchy" {
  for_each = local.role_hierarchy

  role_name        = local.role_name_map[each.key]
  parent_role_name = each.value

  depends_on = [snowflake_account_role.this]
}

# ---------------------------------------------------------------------------
# Warehouse Grants (specific privileges)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "warehouse" {
  for_each = {
    for k, v in local.warehouse_grants : k => v
    if !contains(v.privileges, "ALL")
  }

  account_role_name = each.value.role_name
  privileges        = each.value.privileges
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = each.value.warehouse
  }

  depends_on = [snowflake_account_role.this]
}

# ---------------------------------------------------------------------------
# Warehouse Grants (all privileges)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "warehouse_all" {
  for_each = {
    for k, v in local.warehouse_grants : k => v
    if contains(v.privileges, "ALL")
  }

  account_role_name = each.value.role_name
  all_privileges    = true
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = each.value.warehouse
  }

  depends_on = [snowflake_account_role.this]
}

# ---------------------------------------------------------------------------
# Database Grants (specific privileges)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "database" {
  for_each = {
    for k, v in local.database_grants : k => v
    if !contains(v.privileges, "ALL")
  }

  account_role_name = each.value.role_name
  privileges        = each.value.privileges
  on_account_object {
    object_type = "DATABASE"
    object_name = each.value.database
  }

  depends_on = [snowflake_account_role.this]
}

# ---------------------------------------------------------------------------
# Database Grants (all privileges)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "database_all" {
  for_each = {
    for k, v in local.database_grants : k => v
    if contains(v.privileges, "ALL")
  }

  account_role_name = each.value.role_name
  all_privileges    = true
  on_account_object {
    object_type = "DATABASE"
    object_name = each.value.database
  }

  depends_on = [snowflake_account_role.this]
}

# ---------------------------------------------------------------------------
# Account-level Privileges (e.g. EXECUTE TASK)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "account" {
  for_each = local.account_grants

  account_role_name = each.value.role_name
  privileges        = each.value.privileges
  on_account        = true

  depends_on = [snowflake_account_role.this]
}

# ---------------------------------------------------------------------------
# Future Grants — Schemas
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "future_schemas" {
  for_each = local.future_schema_grants

  account_role_name = each.value.role_name
  all_privileges    = true
  on_schema {
    future_schemas_in_database = each.value.database
  }

  depends_on = [snowflake_account_role.this]
}

# ---------------------------------------------------------------------------
# Future Grants — Objects (Tables, Views, Stages, Pipes, etc.)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "future_objects" {
  for_each = local.future_object_grants

  account_role_name = each.value.role_name
  all_privileges    = true
  on_schema_object {
    future {
      object_type_plural = each.value.object_type_plural
      in_database        = each.value.database
    }
  }

  depends_on = [snowflake_account_role.this]
}
