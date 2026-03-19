locals {
  # Derive unique schemas from table definitions
  schemas = distinct([for t in var.tables : t.schema])
}

# ---------------------------------------------------------------------------
# Schemas (auto-derived from table definitions)
# ---------------------------------------------------------------------------
resource "snowflake_schema" "this" {
  for_each = toset(local.schemas)

  database = var.database_name
  name     = upper(each.key)
  comment  = "Schema for ${each.key} data"
}

# ---------------------------------------------------------------------------
# Tables
# ---------------------------------------------------------------------------
resource "snowflake_table" "this" {
  for_each = var.tables

  database = var.database_name
  schema   = snowflake_schema.this[each.value.schema].name
  name     = upper(each.key)
  comment  = each.value.comment

  dynamic "column" {
    for_each = each.value.columns
    content {
      name     = upper(column.value.name)
      type     = column.value.type
      nullable = column.value.nullable
    }
  }
}
