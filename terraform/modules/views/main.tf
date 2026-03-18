# ---------------------------------------------------------------------------
# Views
# ---------------------------------------------------------------------------
resource "snowflake_view" "this" {
  for_each = var.views

  database  = var.database_name
  schema    = upper(each.value.schema)
  name      = upper(each.key)
  comment   = each.value.comment
  is_secure = each.value.is_secure
  statement = replace(each.value.statement, "{database}", var.database_name)
}
