output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Resource ID of the Azure Resource Group."
  value       = azurerm_resource_group.main.id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.id
}

output "webapp_name" {
  description = "Name of the App Service (Linux Web App)."
  value       = azurerm_linux_web_app.main.name
}

output "webapp_hostname" {
  description = "Default hostname of the App Service."
  value       = azurerm_linux_web_app.main.default_hostname
}

output "webapp_url" {
  description = "HTTPS URL of the App Service."
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "webapp_resource_id" {
  description = "Resource ID of the App Service (used for diagnostics/metrics queries)."
  value       = azurerm_linux_web_app.main.id
}

output "log_analytics_workspace_customer_id" {
  description = "Log Analytics workspace ID (aka customer/workspace ID) used by log queries."
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "budget_name" {
  description = "Name of the Azure budget created for the Resource Group."
  value       = azurerm_consumption_budget_resource_group.monthly.name
}
