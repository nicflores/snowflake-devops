output "view_fqns" {
  description = "Map of view keys to fully qualified names (DB.SCHEMA.VIEW)"
  value = {
    for k, v in snowflake_view.this :
    k => "${v.database}.${v.schema}.${v.name}"
  }
}
