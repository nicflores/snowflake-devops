variable "database_name" {
  type        = string
  description = "Name of the database"
}

variable "loader_role_name" {
  type        = string
  description = "Name of the pre-existing loader role (created by admin)"
}

variable "transformer_role_name" {
  type        = string
  description = "Name of the pre-existing transformer role (created by admin)"
}

variable "analyst_role_name" {
  type        = string
  description = "Name of the pre-existing analyst role (created by admin)"
}
