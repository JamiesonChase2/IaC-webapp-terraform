locals {
  tags = {
    application = var.project_name
    environment = var.environment
    owner       = var.owner
  }

  # Base prefix for resource names (a random suffix is appended per-resource).
  name_prefix             = "${var.project_name}-${var.environment}"
  action_group_short_name = "opsag${random_string.suffix.result}" # must be <= 12 chars
  required_tag_names      = toset(["owner", "environment", "application"])
}
