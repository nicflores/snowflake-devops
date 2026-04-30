variable "name" {
  type        = string
  description = "Name of the warehouse"
}

variable "warehouse_size" {
  type        = string
  description = "Warehouse size (XSMALL, SMALL, MEDIUM, LARGE, XLARGE, etc.)"
  default     = "XSMALL"
}

variable "warehouse_type" {
  type        = string
  description = "Warehouse type (STANDARD or SNOWPARK-OPTIMIZED)"
  default     = "STANDARD"
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

variable "min_cluster_count" {
  type        = number
  description = "Minimum number of clusters for multi-cluster warehouses"
  default     = 1
}

variable "max_cluster_count" {
  type        = number
  description = "Maximum number of clusters for multi-cluster warehouses"
  default     = 1
}

variable "scaling_policy" {
  type        = string
  description = "Auto-scaling policy (STANDARD or ECONOMY)"
  default     = "STANDARD"
}

variable "comment" {
  type        = string
  description = "Warehouse comment"
  default     = null
}
