terraform {
  required_version = ">= 1.3.0"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 1.0"
    }
  }
}

provider "snowflake" {
  organization_name = "ZAXWJSJ"
  account_name      = "ERB51961"
  user              = var.snowflake_user
  authenticator     = "JWT"
  private_key       = var.snowflake_private_key
  role              = var.snowflake_role
}
