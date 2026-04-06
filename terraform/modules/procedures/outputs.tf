# SQL procedure fully qualified names
output "sql_procedure_names" {
  value = { for k, v in snowflake_procedure_sql.this : k => v.fully_qualified_name }
}

# Python procedure fully qualified names
output "python_procedure_names" {
  value = { for k, v in snowflake_procedure_python.this : k => v.fully_qualified_name }
}
