resource "azurerm_monitor_metric_alert" "http5xx" {
  name                = "alert-${local.name_prefix}-${random_string.suffix.result}-http5xx"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_web_app.main.id]
  description         = "Triggers when the web app returns any 5xx in a 5-minute window."
  severity            = 2
  enabled             = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = local.tags
}


resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}-${random_string.suffix.result}"
  location = var.location
  tags     = local.tags

  lifecycle {
    precondition {
      condition     = contains(var.allowed_locations, var.location)
      error_message = "location must be included in allowed_locations (update one or the other)."
    }
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${local.name_prefix}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.tags
}

resource "azurerm_service_plan" "main" {
  name                = "asp-${local.name_prefix}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  os_type  = "Linux"
  sku_name = var.service_plan_sku

  tags = local.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-${local.name_prefix}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    always_on = true

    application_stack {
      node_version = var.node_version
    }
  }

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "webapp_to_law" {
  name                           = "diag-${azurerm_linux_web_app.main.name}"
  target_resource_id             = azurerm_linux_web_app.main.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.id
  log_analytics_destination_type = "Dedicated"

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }

  metric { category = "AllMetrics" }
}

resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${local.name_prefix}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = local.action_group_short_name
  tags                = local.tags

  email_receiver {
    name          = "primary"
    email_address = var.alert_email
  }
}
