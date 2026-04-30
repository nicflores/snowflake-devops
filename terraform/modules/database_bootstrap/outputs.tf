output "account_roles" {
  description = "Created account roles"
  value = {
    admin  = snowflake_account_role.admin.name
    deploy = snowflake_account_role.deploy.name
  }
}

output "global_database_roles" {
  description = "Created global database roles"
  value = {
    ro  = snowflake_database_role.global_ro.fully_qualified_name
    rw  = snowflake_database_role.global_rw.fully_qualified_name
    ddl = snowflake_database_role.global_ddl.fully_qualified_name
  }
}
