# ---------------------------------------------------------------------------
# Schemas & Tables
# (database pre-created and owned by admin tier)
# ---------------------------------------------------------------------------
module "tables" {
  source = "../modules/tables"

  database_name = local.database_name
  tables        = local.tables
}

# ---------------------------------------------------------------------------
# Views
# ---------------------------------------------------------------------------
module "views" {
  source = "../modules/views"

  database_name = local.database_name
  views         = local.views

  depends_on = [module.tables]
}

# ---------------------------------------------------------------------------
# Functions (SQL & Snowpark UDFs)
# ---------------------------------------------------------------------------
module "functions" {
  source = "../modules/functions"

  database_name = local.database_name
  functions     = local.functions

  depends_on = [module.tables]
}

# ---------------------------------------------------------------------------
# Procedures (SQL & Snowpark Stored Procedures)
# ---------------------------------------------------------------------------
module "procedures" {
  source = "../modules/procedures"

  database_name = local.database_name
  procedures    = local.procedures

  depends_on = [module.tables]
}

# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------
module "tasks" {
  source = "../modules/tasks"

  database_name  = local.database_name
  warehouse_name = local.warehouse_name
  tasks          = local.tasks

  depends_on = [module.tables]
}

# ---------------------------------------------------------------------------
# Ingestion — Stages, File Formats, Pipes
# Uncomment once a storage integration is defined in admin/config/databases.yaml
# ---------------------------------------------------------------------------
# module "ingestion" {
#   source = "../modules/ingestion"
#
#   environment              = var.environment
#   database_name            = local.database_name
#   storage_integration_name = "<INTEGRATION_NAME>"
#   storage_sources          = local.storage_sources
#   tables                   = local.tables
#
#   depends_on = [module.tables]
# }
