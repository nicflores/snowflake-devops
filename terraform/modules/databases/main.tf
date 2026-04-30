locals {
  db_names = {
    for k, v in var.databases :
    k => upper("${var.env_prefix}_${lookup(v, "name", upper(k))}")
  }
}

resource "snowflake_database" "this" {
  for_each = var.databases

  name    = local.db_names[each.key]
  comment = lookup(each.value, "comment", "${local.db_names[each.key]} — ${upper(var.environment)} environment")
}
