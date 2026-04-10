# ---------------------------------------------------------------------------
# Computed values used across developer-tier modules
# ---------------------------------------------------------------------------
locals {
  name_prefix = "BACKOFFICE"

  # Must match the naming convention in admin/locals.tf
  database_name            = upper("${var.environment}_${local.name_prefix}_DB")
  storage_integration_name = upper("AZURE_${var.environment}_INTEGRATION")

  # Role names — must match what admin tier creates
  loader_role_name      = upper("${var.environment}_LOADER")
  transformer_role_name = upper("${var.environment}_TRANSFORMER")
  analyst_role_name     = upper("${var.environment}_ANALYST")

  # Must match the naming convention in admin/locals.tf
  warehouse_name = upper("${var.environment}_${local.name_prefix}_WH")

  # Shared configuration from YAML (developer configs)
  # try() catches yamldecode errors for files that contain only comments / no data
  tables          = try(yamldecode(file("${path.module}/../config/developers/tables.yaml")), {})
  storage_sources = try(yamldecode(file("${path.module}/../config/admin/storage_sources.yaml")), {})
  views           = try(yamldecode(file("${path.module}/../config/developers/views.yaml")), {})
  functions_raw   = try(yamldecode(file("${path.module}/../config/developers/functions.yaml")), {})
  functions = {
    for k, v in local.functions_raw : k => merge(v, {
      body = lookup(v, "body_file", null) != null ? file("${path.module}/../../${v.body_file}") : lookup(v, "body", "")
    })
  }
  tasks_raw = try(yamldecode(file("${path.module}/../config/developers/tasks.yaml")), {})
  tasks = {
    for k, v in local.tasks_raw : k => merge(v, {
      sql_statement = lookup(v, "sql_file", null) != null ? file("${path.module}/../../${v.sql_file}") : lookup(v, "sql_statement", "")
    })
  }
  procedures_raw = try(yamldecode(file("${path.module}/../config/developers/procedures.yaml")), {})
  procedures = {
    for k, v in local.procedures_raw : k => merge(v, {
      body = lookup(v, "body_file", null) != null ? file("${path.module}/../../${v.body_file}") : lookup(v, "body", "")
    })
  }
}
