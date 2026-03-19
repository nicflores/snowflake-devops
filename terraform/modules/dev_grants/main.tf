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
    all {
      object_type_plural = "TABLES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_future_tables" {
  account_role_name = var.loader_role_name
  privileges        = ["INSERT", "SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_tables" {
  account_role_name = var.transformer_role_name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_future_tables" {
  account_role_name = var.transformer_role_name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_tables" {
  account_role_name = var.analyst_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_future_tables" {
  account_role_name = var.analyst_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = var.database_name
    }
  }
}

# ---------------------------------------------------------------------------
# Stage & Pipe Grants (LOADER only)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "loader_stages" {
  account_role_name = var.loader_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    all {
      object_type_plural = "STAGES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_future_stages" {
  account_role_name = var.loader_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    future {
      object_type_plural = "STAGES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_pipes" {
  account_role_name = var.loader_role_name
  privileges        = ["OPERATE", "MONITOR"]
  on_schema_object {
    all {
      object_type_plural = "PIPES"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "loader_future_pipes" {
  account_role_name = var.loader_role_name
  privileges        = ["OPERATE", "MONITOR"]
  on_schema_object {
    future {
      object_type_plural = "PIPES"
      in_database        = var.database_name
    }
  }
}

# ---------------------------------------------------------------------------
# View Grants
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "transformer_views" {
  account_role_name = var.transformer_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_future_views" {
  account_role_name = var.transformer_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_views" {
  account_role_name = var.analyst_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_future_views" {
  account_role_name = var.analyst_role_name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = var.database_name
    }
  }
}

# ---------------------------------------------------------------------------
# Function Grants
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "transformer_functions" {
  account_role_name = var.transformer_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    all {
      object_type_plural = "FUNCTIONS"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_future_functions" {
  account_role_name = var.transformer_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    future {
      object_type_plural = "FUNCTIONS"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_functions" {
  account_role_name = var.analyst_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    all {
      object_type_plural = "FUNCTIONS"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_future_functions" {
  account_role_name = var.analyst_role_name
  privileges        = ["USAGE"]
  on_schema_object {
    future {
      object_type_plural = "FUNCTIONS"
      in_database        = var.database_name
    }
  }
}

# ---------------------------------------------------------------------------
# Task Grants (TRANSFORMER operates tasks)
# ---------------------------------------------------------------------------
resource "snowflake_grant_privileges_to_account_role" "transformer_tasks" {
  account_role_name = var.transformer_role_name
  privileges        = ["OPERATE", "MONITOR"]
  on_schema_object {
    all {
      object_type_plural = "TASKS"
      in_database        = var.database_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "transformer_future_tasks" {
  account_role_name = var.transformer_role_name
  privileges        = ["OPERATE", "MONITOR"]
  on_schema_object {
    future {
      object_type_plural = "TASKS"
      in_database        = var.database_name
    }
  }
}
