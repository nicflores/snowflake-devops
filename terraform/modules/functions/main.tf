# ---------------------------------------------------------------------------
# User-Defined Functions (split by language for provider v2)
# ---------------------------------------------------------------------------

locals {
  sql_functions    = { for k, v in var.functions : k => v if upper(v.language) == "SQL" }
  python_functions = { for k, v in var.functions : k => v if upper(v.language) == "PYTHON" }
}

# ---------------------------------------------------------------------------
# SQL Functions
# ---------------------------------------------------------------------------
resource "snowflake_function_sql" "this" {
  for_each = local.sql_functions

  database = var.database_name
  schema   = upper(each.value.schema)
  name     = upper(each.key)
  comment  = each.value.comment

  return_type         = each.value.return_type
  function_definition = replace(each.value.body, "{database}", var.database_name)

  dynamic "arguments" {
    for_each = each.value.arguments
    content {
      arg_name      = upper(arguments.value.name)
      arg_data_type = arguments.value.type
    }
  }
}

# ---------------------------------------------------------------------------
# Python Functions (Snowpark UDFs)
# ---------------------------------------------------------------------------
resource "snowflake_function_python" "this" {
  for_each = local.python_functions

  database = var.database_name
  schema   = upper(each.value.schema)
  name     = upper(each.key)
  comment  = each.value.comment

  return_type         = each.value.return_type
  runtime_version     = each.value.runtime_version
  handler             = each.value.handler
  packages            = each.value.packages
  function_definition = replace(each.value.body, "{database}", var.database_name)

  dynamic "arguments" {
    for_each = each.value.arguments
    content {
      arg_name      = upper(arguments.value.name)
      arg_data_type = arguments.value.type
    }
  }
}
