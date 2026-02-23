variable "project_name" {
  type        = string
  description = "Application/project identifier used for naming and the 'application' tag."
  default     = "ops-ready-webapp"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, digits, and hyphens (example: ops-ready-webapp)."
  }
}

variable "environment" {
  type        = string
  description = "Environment name used for naming and the 'environment' tag (example: dev, test, prod)."
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment must contain only lowercase letters, digits, and hyphens (example: dev)."
  }
}

variable "location" {
  type        = string
  description = "Azure region for regional resources. Should be included in allowed_locations."
  default     = "eastus"

  validation {
    condition     = var.location == lower(var.location)
    error_message = "location must be lowercase (example: eastus)."
  }
}

variable "owner" {
  type        = string
  description = "Owner tag value (your name or email)."

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner must be a non-empty string."
  }
}

variable "alert_email" {
  type        = string
  description = "Email for alerting (Action Group + budget notifications)."

  validation {
    condition     = can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.alert_email))
    error_message = "alert_email must look like an email address."
  }
}

variable "budget_amount" {
  type        = number
  description = "Monthly budget amount (USD) for the resource group."
  default     = 50

  validation {
    condition     = var.budget_amount > 0
    error_message = "budget_amount must be greater than 0."
  }
}

variable "budget_start_date" {
  type        = string
  description = "Budget start date (RFC3339). Use the first day of a month at midnight UTC (example: 2026-02-01T00:00:00Z)."
  default     = "2026-02-01T00:00:00Z"

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-01T00:00:00Z$", var.budget_start_date))
    error_message = "budget_start_date must be RFC3339 and the 1st of the month at 00:00:00Z (example: 2026-02-01T00:00:00Z)."
  }
}

variable "budget_end_date" {
  type        = string
  description = "Budget end date (RFC3339). Use the first day of a month at midnight UTC (example: 2027-02-01T00:00:00Z)."
  default     = "2027-02-01T00:00:00Z"

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-01T00:00:00Z$", var.budget_end_date))
    error_message = "budget_end_date must be RFC3339 and the 1st of the month at 00:00:00Z (example: 2027-02-01T00:00:00Z)."
  }
}

variable "service_plan_sku" {
  type        = string
  description = "App Service plan SKU (example: B1)."
  default     = "B1"

  validation {
    condition     = can(regex("^[A-Za-z0-9]+$", var.service_plan_sku))
    error_message = "service_plan_sku must be alphanumeric (example: B1)."
  }
}

variable "node_version" {
  type        = string
  description = "Node.js version for App Service Linux runtime."
  default     = "20-lts"

  validation {
    condition     = can(regex("^[0-9]+(-lts)?$", var.node_version))
    error_message = "node_version must look like an App Service Node version (example: 20-lts)."
  }
}

variable "allowed_locations" {
  type        = list(string)
  description = "Azure regions allowed by policy for this resource group. Update this list to match your subscription's allowed regions."
  default     = ["mexicocentral", "norwayeast", "eastus", "southcentralus", "westus3"]

  validation {
    condition = (
      length(var.allowed_locations) > 0 &&
      length(distinct(var.allowed_locations)) == length(var.allowed_locations) &&
      alltrue([for loc in var.allowed_locations : loc == lower(loc)])
    )
    error_message = "allowed_locations must be a non-empty, lowercase, unique list (example: [\"eastus\",\"westus3\"])."
  }
}
