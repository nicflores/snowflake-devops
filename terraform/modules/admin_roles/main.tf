# ---------------------------------------------------------------------------
# Roles
# ---------------------------------------------------------------------------
resource "snowflake_account_role" "loader" {
  name    = upper("${var.environment}_LOADER")
  comment = "Data loading role for ${upper(var.environment)}"
}

resource "snowflake_account_role" "transformer" {
  name    = upper("${var.environment}_TRANSFORMER")
  comment = "Data transformation role for ${upper(var.environment)}"
}

resource "snowflake_account_role" "analyst" {
  name    = upper("${var.environment}_ANALYST")
  comment = "Read-only analyst role for ${upper(var.environment)}"
}

# ---------------------------------------------------------------------------
# Role Hierarchy — custom roles roll up to SYSADMIN
# ---------------------------------------------------------------------------
resource "snowflake_grant_account_role" "loader_to_sysadmin" {
  role_name        = snowflake_account_role.loader.name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_account_role" "transformer_to_sysadmin" {
  role_name        = snowflake_account_role.transformer.name
  parent_role_name = "SYSADMIN"
}

resource "snowflake_grant_account_role" "analyst_to_sysadmin" {
  role_name        = snowflake_account_role.analyst.name
  parent_role_name = "SYSADMIN"
}

# ---------------------------------------------------------------------------
# Warehouse Grants
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "loader_wh" {
  account_role_name = snowflake_account_role.loader.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_wh" {
  account_role_name = snowflake_account_role.transformer.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_wh" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

# ---------------------------------------------------------------------------
# Database Grants
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "loader_db" {
  account_role_name = snowflake_account_role.loader.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.database_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_db" {
  account_role_name = snowflake_account_role.transformer.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.database_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_db" {
  account_role_name = snowflake_account_role.analyst.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = var.database_name
  }
}

# ---------------------------------------------------------------------------
# CI/CD Role — grant ownership-level privileges on the database
# so the developer-tier Terraform can create schemas, tables, stages, etc.
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "cicd_db_all" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_account_object {
    object_type = "DATABASE"
    object_name = var.database_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_schemas" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema { future_schemas_in_database = var.database_name }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_tables" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema_object {
    future { object_type_plural = "TABLES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_stages" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema_object {
    future { object_type_plural = "STAGES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_file_formats" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema_object {
    future { object_type_plural = "FILE FORMATS"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_pipes" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema_object {
    future { object_type_plural = "PIPES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_views" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema_object {
    future { object_type_plural = "VIEWS"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_functions" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema_object {
    future { object_type_plural = "FUNCTIONS"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "cicd_tasks" {
  account_role_name = var.cicd_role_name
  all_privileges    = true
  on_schema_object {
    future { object_type_plural = "TASKS"; in_database = var.database_name }
  }
}

# Grant EXECUTE TASK so tasks can actually run
resource "snowflake_grant_privileges_to_account_role" "cicd_execute_task" {
  account_role_name = var.cicd_role_name
  privileges        = ["EXECUTE TASK"]
  on_account        = true
}

# Grant USAGE on the storage integration to the CI/CD role so it can create stages
resource "snowflake_grant_privileges_to_account_role" "cicd_wh" {
  account_role_name = var.cicd_role_name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}
