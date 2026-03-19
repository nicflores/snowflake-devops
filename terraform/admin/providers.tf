terraform {
  required_version = ">= 1.3.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "2.14.0"
    }
  }
}

provider "snowflake" {
  organization_name = "ZAXWJSJ"
  account_name      = "ERB51961"
  user              = var.snowflake_user
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = var.snowflake_private_key
  role              = var.snowflake_role

  preview_features_enabled = [
    "snowflake_storage_integration_azure_resource",
  ]
}
