# ---------------------------------------------------------------------------
# Schema Grants — all current + future schemas
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "loader_schemas" {
  account_role_name = var.loader_role_name
  privileges        = ["USAGE"]
  on_schema { all_schemas_in_database = var.database_name }
}

resource "snowflake_grant_privileges_to_account_role" "loader_future_schemas" {
  account_role_name = var.loader_role_name
  privileges        = ["USAGE"]
  on_schema { future_schemas_in_database = var.database_name }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_schemas" {
  account_role_name = var.transformer_role_name
  privileges        = ["USAGE"]
  on_schema { all_schemas_in_database = var.database_name }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_future_schemas" {
  account_role_name = var.transformer_role_name
  privileges        = ["USAGE"]
  on_schema { future_schemas_in_database = var.database_name }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_schemas" {
  account_role_name = var.analyst_role_name
  privileges        = ["USAGE"]
  on_schema { all_schemas_in_database = var.database_name }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_future_schemas" {
  account_role_name = var.analyst_role_name
  privileges        = ["USAGE"]
  on_schema { future_schemas_in_database = var.database_name }
}

# ---------------------------------------------------------------------------
# Table Grants
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "loader_tables" {
  account_role_name = var.loader_role_name
  privileges        = ["INSERT", "SELECT"]
  on_schema_object {
    all { object_type_plural = "TABLES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_future_tables" {
  account_role_name = var.loader_role_name
  privileges        = ["INSERT", "SELECT"]
  on_schema_object {
    future { object_type_plural = "TABLES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_tables" {
  account_role_name = var.transformer_role_name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    all { object_type_plural = "TABLES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_future_tables" {
  account_role_name = var.transformer_role_name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    future { object_type_plural = "TABLES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_tables" {
  account_role_name = var.analyst_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    all { object_type_plural = "TABLES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_future_tables" {
  account_role_name = var.analyst_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    future { object_type_plural = "TABLES"; in_database = var.database_name }
  }
}

# ---------------------------------------------------------------------------
# Stage & Pipe Grants (LOADER only)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "loader_stages" {
  account_role_name = var.loader_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    all { object_type_plural = "STAGES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_future_stages" {
  account_role_name = var.loader_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    future { object_type_plural = "STAGES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_pipes" {
  account_role_name = var.loader_role_name
  privileges        = ["OPERATE", "MONITOR"]
  on_schema_object {
    all { object_type_plural = "PIPES"; in_database = var.database_name }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_future_pipes" {
  account_role_name = var.loader_role_name
  privileges        = ["OPERATE", "MONITOR"]
  on_schema_object {
    future { object_type_plural = "PIPES"; in_database = var.database_name }
  }
}
