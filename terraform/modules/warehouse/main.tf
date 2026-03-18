resource "snowflake_warehouse" "this" {
  name           = var.name
  warehouse_size = upper(var.warehouse_size)
  auto_suspend   = var.auto_suspend
  auto_resume    = var.auto_resume

  initially_suspended = true
}
