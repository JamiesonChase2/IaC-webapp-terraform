/*
Simple cloud financial controls.
*/

resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "bud-${local.name_prefix}-${random_string.suffix.result}"
  resource_group_id = azurerm_resource_group.main.id

  amount     = var.budget_amount
  time_grain = "Monthly"

  lifecycle {
    precondition {
      # Keep the budget period sane; fails fast if dates are reversed.
      condition     = var.budget_end_date > var.budget_start_date
      error_message = "budget_end_date must be later than budget_start_date."
    }
  }

  time_period {
    start_date = var.budget_start_date
    end_date   = var.budget_end_date
  }

  # Notifications based on ACTUAL spend (not forecast).
  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 50
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
    contact_groups = [azurerm_monitor_action_group.main.id]
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 80
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
    contact_groups = [azurerm_monitor_action_group.main.id]
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
    contact_groups = [azurerm_monitor_action_group.main.id]
  }
}
