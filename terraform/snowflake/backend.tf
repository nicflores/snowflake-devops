# -----------------------------------------------------------------------------
# Terraform Backend — Azure Blob Storage
# -----------------------------------------------------------------------------
# The state file key is set per environment during `terraform init`:
#
#   terraform init -backend-config="key=snowflake/dev/terraform.tfstate"
#   terraform init -backend-config="key=snowflake/prod/terraform.tfstate"
#
# Before first run, create the backend resources:
#
#   az group create --name rg-terraform-state --location eastus
#   az storage account create \
#     --name <unique-name> \
#     --resource-group rg-terraform-state \
#     --sku Standard_LRS \
#     --encryption-services blob
#   az storage container create \
#     --name tfstate \
#     --account-name <unique-name>
#
# Set ARM_ACCESS_KEY in your environment so the azurerm backend can authenticate.
# -----------------------------------------------------------------------------
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"   # TODO: update
    storage_account_name = "tfstatesnowflake"      # TODO: update
    container_name       = "tfstate"
    # key is supplied at init time via -backend-config
  }
}
