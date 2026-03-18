locals {
  # Tables that reference a storage source — each gets a pipe
  tables_with_source = {
    for k, v in var.tables : k => v if v.source != ""
  }
}

# ---------------------------------------------------------------------------
# File Formats (one per storage source)
# ---------------------------------------------------------------------------
resource "snowflake_file_format" "this" {
  for_each = var.storage_sources

  database = var.database_name
  schema   = upper(each.value.schema)
  name     = upper("${each.key}_FORMAT")

  format_type                  = each.value.file_format.type
  skip_header                  = each.value.file_format.skip_header
  field_delimiter              = each.value.file_format.field_delimiter
  field_optionally_enclosed_by = each.value.file_format.field_optionally_enclosed_by
  null_if                      = each.value.file_format.null_if
}

# ---------------------------------------------------------------------------
# External Stages (one per storage source)
# ---------------------------------------------------------------------------
resource "snowflake_stage" "this" {
  for_each = var.storage_sources

  database            = var.database_name
  schema              = upper(each.value.schema)
  name                = upper("${each.key}_STAGE")
  url                 = "azure://${each.value.storage_account_name}.blob.core.windows.net/${each.value.container_name}/${each.value.path_prefix}/"
  storage_integration = var.storage_integration_name
}

# ---------------------------------------------------------------------------
# Snowpipe — one pipe per table that has a source
# ---------------------------------------------------------------------------
resource "snowflake_pipe" "this" {
  for_each = local.tables_with_source

  database = var.database_name
  schema   = upper(each.value.schema)
  name     = upper("${each.key}_PIPE")

  auto_ingest = true

  copy_statement = join(" ", [
    "COPY INTO ${var.database_name}.${upper(each.value.schema)}.${upper(each.key)}",
    "FROM @${var.database_name}.${upper(each.value.schema)}.${upper(each.value.source)}_STAGE",
    "FILE_FORMAT = (FORMAT_NAME = '${var.database_name}.${upper(each.value.schema)}.${upper(each.value.source)}_FORMAT')",
  ])

  depends_on = [
    snowflake_stage.this,
    snowflake_file_format.this,
  ]
}
