terraform {
  # required_version = ">= 1.3.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "2.14.0"
    }
  }
}

# -----------------------------------------------------------------------------
# Key-pair authentication
# -----------------------------------------------------------------------------
# Generate an RSA key pair for the Terraform service account:
#
#   openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_key.p8 -nocrypt
#   openssl rsa -in snowflake_key.p8 -pubout -out snowflake_key.pub
#
# In Snowflake, assign the public key to the user:
#
#   ALTER USER <user> SET RSA_PUBLIC_KEY='<contents of snowflake_key.pub without header/footer>';
#
# Pass the private key via TF_VAR_snowflake_private_key (the full PEM content).
# -----------------------------------------------------------------------------
provider "snowflake" {
  organization_name = "ZAXWJSJ"
  account_name      = "ERB51961"
  user              = var.snowflake_user
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = var.snowflake_private_key
  role              = var.snowflake_role

  preview_features_enabled = [
    "snowflake_table_resource",
    "snowflake_file_format_resource",
    "snowflake_stage_resource",
    "snowflake_pipe_resource",
    "snowflake_function_sql_resource",
    "snowflake_function_python_resource",
    "snowflake_procedure_sql_resource",
    "snowflake_procedure_python_resource",
  ]
}
