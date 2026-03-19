variable "name" {
  type        = string
  description = "Name of the warehouse"
}

variable "environment" {
  type        = string
  description = "Environment name (DEV, PROD, UAT, etc.)"
}

variable "warehouse_size" {
  type        = string
  description = "Warehouse size (XSMALL, SMALL, MEDIUM, LARGE, XLARGE, etc.)"
  default     = "XSMALL"
}

variable "auto_suspend" {
  type        = number
  description = "Seconds of inactivity before the warehouse is automatically suspended"
  default     = 60
}

variable "auto_resume" {
  type        = string
  description = "Whether the warehouse automatically resumes when a query is submitted (true/false/default)"
  default     = "true"
}
