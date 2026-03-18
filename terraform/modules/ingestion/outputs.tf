output "stage_names" {
  description = "Map of source keys to their stage names"
  value       = { for k, v in snowflake_stage.this : k => v.name }
}

output "pipe_names" {
  description = "Map of table keys to their pipe names"
  value       = { for k, v in snowflake_pipe.this : k => v.name }
}

output "pipe_notification_channels" {
  description = "Map of table keys to pipe notification channels (for Azure Event Grid)"
  value       = { for k, v in snowflake_pipe.this : k => v.notification_channel }
}
