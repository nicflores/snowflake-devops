# ---------------------------------------------------------------------------
# User-Defined Functions (SQL & Snowpark)
# ---------------------------------------------------------------------------
resource "snowflake_function" "this" {
  for_each = var.functions

  database = var.database_name
  schema   = upper(each.value.schema)
  name     = upper(each.key)
  comment  = each.value.comment

  return_type = each.value.return_type
  language    = upper(each.value.language)
  statement   = replace(each.value.body, "{database}", var.database_name)

  dynamic "arguments" {
    for_each = each.value.arguments
    content {
      name = upper(arguments.value.name)
      type = arguments.value.type
    }
  }

  runtime_version = each.value.runtime_version
  packages        = length(each.value.packages) > 0 ? each.value.packages : null
  handler         = each.value.handler
}
