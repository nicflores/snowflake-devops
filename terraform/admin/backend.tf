# -----------------------------------------------------------------------------
# Terraform Backend — Azure Blob Storage
# -----------------------------------------------------------------------------
# Separate state from the developer tier. Key is set at init time:
#
#   terraform init -backend-config="key=admin/dev/terraform.tfstate"
#   terraform init -backend-config="key=admin/prod/terraform.tfstate"
# -----------------------------------------------------------------------------
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state" # TODO: update
    storage_account_name = "tfstatesnowflake"   # TODO: update
    container_name       = "tfstate"
    # key is supplied at init time via -backend-config
  }
}
