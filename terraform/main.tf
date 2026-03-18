# Terraform root configurations live under terraform/snowflake/
#
# To work with an environment:
#   cd terraform/snowflake
#   terraform init -backend-config="key=snowflake/dev/terraform.tfstate"
#   terraform plan  -var-file=environments/DEV/DEV.tfvars
#   terraform apply -var-file=environments/DEV/DEV.tfvars
#
# See terraform/config/ for shared table and storage source definitions.
