# ---------------------------------------------------------------------------
# Stored Procedures (split by language for provider v2)
# ---------------------------------------------------------------------------

locals {
  sql_procedures    = { for k, v in var.procedures : k => v if upper(v.language) == "SQL" }
  python_procedures = { for k, v in var.procedures : k => v if upper(v.language) == "PYTHON" }
}

# ---------------------------------------------------------------------------
# SQL Procedures
# ---------------------------------------------------------------------------
resource "snowflake_procedure_sql" "this" {
  for_each = local.sql_procedures

  database = var.database_name
  schema   = upper(each.value.schema)
  name     = upper(each.key)
  comment  = each.value.comment

  return_type          = each.value.return_type
  procedure_definition = replace(each.value.body, "{database}", var.database_name)
  execute_as           = each.value.execute_as
  null_input_behavior  = each.value.null_input_behavior

  dynamic "arguments" {
    for_each = each.value.arguments
    content {
      arg_name      = upper(arguments.value.name)
      arg_data_type = arguments.value.type
    }
  }
}

# ---------------------------------------------------------------------------
# Python Procedures (Snowpark)
# ---------------------------------------------------------------------------
resource "snowflake_procedure_python" "this" {
  for_each = local.python_procedures

  database = var.database_name
  schema   = upper(each.value.schema)
  name     = upper(each.key)
  comment  = each.value.comment

  return_type          = each.value.return_type
  runtime_version      = each.value.runtime_version
  handler              = each.value.handler
  snowpark_package     = each.value.snowpark_package
  packages             = each.value.packages
  procedure_definition = replace(each.value.body, "{database}", var.database_name)
  execute_as           = each.value.execute_as
  null_input_behavior  = each.value.null_input_behavior

  dynamic "arguments" {
    for_each = each.value.arguments
    content {
      arg_name      = upper(arguments.value.name)
      arg_data_type = arguments.value.type
    }
  }
}
