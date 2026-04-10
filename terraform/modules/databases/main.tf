resource "snowflake_database" "this" {
  for_each = var.databases

  name    = upper("${var.environment}_${each.key}_DB")
  comment = "${upper("${var.environment}_${each.key}_DB")} — ${upper(var.environment)} environment"
}
