# ---------------------------------------------------------------------------
# Computed values used across developer-tier modules
# ---------------------------------------------------------------------------
locals {
  # Developer configuration from YAML
  # try() catches yamldecode errors for files that contain only comments / no data
  tables_raw = try(tomap(yamldecode(file("${path.module}/config/tables.yaml"))), {})
  tables = {
    for k, v in local.tables_raw : k => merge(v, {
      database_name = upper("${var.env_prefix}_${v.database}")
    })
  }

  views_raw = try(tomap(yamldecode(file("${path.module}/config/views.yaml"))), {})
  views = {
    for k, v in local.views_raw : k => merge(v, {
      database_name = upper("${var.env_prefix}_${v.database}")
    })
  }

  functions_raw = try(tomap(yamldecode(file("${path.module}/config/functions.yaml"))), {})
  functions = {
    for k, v in local.functions_raw : k => merge(v, {
      database_name = upper("${var.env_prefix}_${v.database}")
      body          = lookup(v, "body_file", null) != null ? file("${path.module}/../../${v.body_file}") : lookup(v, "body", "")
    })
  }

  procedures_raw = try(tomap(yamldecode(file("${path.module}/config/procedures.yaml"))), {})
  procedures = {
    for k, v in local.procedures_raw : k => merge(v, {
      database_name = upper("${var.env_prefix}_${v.database}")
      body          = lookup(v, "body_file", null) != null ? file("${path.module}/../../${v.body_file}") : lookup(v, "body", "")
    })
  }

  tasks_raw = try(tomap(yamldecode(file("${path.module}/config/tasks.yaml"))), {})
  tasks = {
    for k, v in local.tasks_raw : k => merge(v, {
      database_name  = upper("${var.env_prefix}_${v.database}")
      warehouse_name = upper("${var.env_prefix}_${v.warehouse}_WH")
      sql_statement  = lookup(v, "sql_file", null) != null ? file("${path.module}/../../${v.sql_file}") : lookup(v, "sql_statement", "")
    })
  }
}
