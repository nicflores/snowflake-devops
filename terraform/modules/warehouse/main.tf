resource "snowflake_warehouse" "this" {
  name              = var.name
  warehouse_type    = upper(var.warehouse_type)
  warehouse_size    = upper(var.warehouse_size)
  auto_suspend      = var.auto_suspend
  auto_resume       = var.auto_resume
  min_cluster_count = var.min_cluster_count
  max_cluster_count = var.max_cluster_count
  scaling_policy    = upper(var.scaling_policy)
  comment           = var.comment

  initially_suspended = true
}
