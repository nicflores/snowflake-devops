output "database_name" {
  value = local.database_name
}

output "schema_names" {
  value = module.database.schema_names
}

output "table_fqns" {
  value = module.database.table_fqns
}

output "pipe_notification_channels" {
  description = "Notification channels for Azure Event Grid subscriptions"
  value       = module.ingestion.pipe_notification_channels
}
