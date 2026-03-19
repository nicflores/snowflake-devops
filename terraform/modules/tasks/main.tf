# ---------------------------------------------------------------------------
# Snowflake Tasks
# ---------------------------------------------------------------------------

locals {
  # Separate root tasks (have a schedule) from child tasks (have "after")
  root_tasks  = { for k, v in var.tasks : k => v if v.after == null }
  child_tasks = { for k, v in var.tasks : k => v if v.after != null }
}

# ---------------------------------------------------------------------------
# Root Tasks (scheduled)
# ---------------------------------------------------------------------------
resource "snowflake_task" "root" {
  for_each = local.root_tasks

  database  = var.database_name
  schema    = upper(each.value.schema)
  name      = upper(each.key)
  comment   = each.value.comment
  warehouse = var.warehouse_name
  started   = each.value.started

  dynamic "schedule" {
    for_each = each.value.schedule != null ? [each.value.schedule] : []
    content {
      minutes    = schedule.value.minutes
      hours      = schedule.value.hours
      using_cron = schedule.value.using_cron
    }
  }

  sql_statement = replace(
    replace(each.value.sql_statement, "{database}", var.database_name),
    "{warehouse}", var.warehouse_name
  )
}

# ---------------------------------------------------------------------------
# Child Tasks (run after a parent task)
# ---------------------------------------------------------------------------
resource "snowflake_task" "child" {
  for_each = local.child_tasks

  database  = var.database_name
  schema    = upper(each.value.schema)
  name      = upper(each.key)
  comment   = each.value.comment
  warehouse = var.warehouse_name
  after     = [snowflake_task.root[each.value.after].fully_qualified_name]
  started   = each.value.started

  sql_statement = replace(
    replace(each.value.sql_statement, "{database}", var.database_name),
    "{warehouse}", var.warehouse_name
  )
}
