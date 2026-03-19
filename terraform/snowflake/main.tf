# ---------------------------------------------------------------------------
# Schemas & Tables (database pre-created by admin tier)
# ---------------------------------------------------------------------------
module "tables" {
  source = "../modules/tables"

  database_name = local.database_name
  tables        = local.tables
}

# ---------------------------------------------------------------------------
# Ingestion — Stages, File Formats, Pipes
# (storage integration pre-created by admin tier)
# ---------------------------------------------------------------------------
# module "ingestion" {
#   source = "../modules/ingestion"
#   environment              = var.environment
#   database_name            = local.database_name
#   storage_integration_name = local.storage_integration_name
#   storage_sources          = local.storage_sources
#   tables                   = local.tables
#   depends_on = [module.tables]
# }

# ---------------------------------------------------------------------------
# Views
# ---------------------------------------------------------------------------
# module "views" {
#   source = "../modules/views"

#   database_name = local.database_name
#   views         = local.views

#   depends_on = [module.tables]
# }

# ---------------------------------------------------------------------------
# Functions (SQL & Snowpark UDFs)
# ---------------------------------------------------------------------------
# module "functions" {
#   source = "../modules/functions"

#   database_name = local.database_name
#   functions     = local.functions

#   depends_on = [module.tables]
# }

# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------
# module "tasks" {
#   source = "../modules/tasks"

#   database_name  = local.database_name
#   warehouse_name = local.warehouse_name
#   tasks          = local.tasks

#   depends_on = [module.tables]
# }

# ---------------------------------------------------------------------------
# Grants — schema/table/stage/pipe/view/function/task level grants
# ---------------------------------------------------------------------------
# module "dev_grants" {
#   source = "../modules/dev_grants"

#   database_name         = local.database_name
#   loader_role_name      = local.loader_role_name
#   transformer_role_name = local.transformer_role_name
#   analyst_role_name     = local.analyst_role_name

#   depends_on = [module.tables, module.ingestion, module.views, module.functions, module.tasks]
# }
