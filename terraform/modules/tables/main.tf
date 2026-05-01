locals {
  # Unique (database, schema) pairs — keyed as "DATABASE__SCHEMA" for for_each
  schema_pairs = {
    for pair in distinct([
      for t in var.tables : { database = t.database_name, schema = upper(t.schema) }
    ]) : "${pair.database}__${pair.schema}" => pair
  }
}

# ---------------------------------------------------------------------------
# Schemas (auto-derived from table definitions)
# ---------------------------------------------------------------------------
resource "snowflake_schema" "this" {
  for_each = local.schema_pairs

  database = each.value.database
  name     = each.value.schema
  comment  = "Schema for ${each.value.schema} data"
}

# ---------------------------------------------------------------------------
# Tables
# ---------------------------------------------------------------------------
resource "snowflake_table" "this" {
  for_each = var.tables

  database = each.value.database_name
  schema   = snowflake_schema.this["${each.value.database_name}__${upper(each.value.schema)}"].name
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
