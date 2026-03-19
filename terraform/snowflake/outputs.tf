output "database_name" {
  value = local.database_name
}

output "schema_names" {
  value = module.tables.schema_names
}

output "table_fqns" {
  value = module.tables.table_fqns
}

# output "pipe_notification_channels" {
#   description = "Notification channels for Azure Event Grid subscriptions"
#   value       = module.ingestion.pipe_notification_channels
# }

# output "view_fqns" {
#   value = module.views.view_fqns
# }

# output "function_fqns" {
#   value = module.functions.function_fqns
# }

# output "task_fqns" {
#   value = module.tasks.task_fqns
# }
