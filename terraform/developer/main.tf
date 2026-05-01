# ---------------------------------------------------------------------------
# Schemas & Tables
# (database pre-created and owned by admin tier)
# ---------------------------------------------------------------------------
module "tables" {
  source = "../modules/tables"

  tables = local.tables
}

# ---------------------------------------------------------------------------
# Views
# ---------------------------------------------------------------------------
module "views" {
  source = "../modules/views"

  views = local.views

  depends_on = [module.tables]
}

# ---------------------------------------------------------------------------
# Functions (SQL & Snowpark UDFs)
# ---------------------------------------------------------------------------
module "functions" {
  source = "../modules/functions"

  functions = local.functions

  depends_on = [module.tables]
}

# ---------------------------------------------------------------------------
# Procedures (SQL & Snowpark Stored Procedures)
# ---------------------------------------------------------------------------
module "procedures" {
  source = "../modules/procedures"

  procedures = local.procedures

  depends_on = [module.tables]
}

# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------
module "tasks" {
  source = "../modules/tasks"

  tasks = local.tasks

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
#   storage_integration_name = "<INTEGRATION_NAME>"
#   storage_sources          = local.storage_sources
#   tables                   = local.tables
#
#   depends_on = [module.tables]
# }
