/*
Guardrails (Azure Policy) scoped to the Resource Group.

Important:
- These are *assignments* of Azure Policy definitions.
- Effects are deny, so noncompliant resources will fail to deploy.
*/

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  # Built-in policy: "Allowed locations"
  name                 = "pa-allowed-loc-${random_string.suffix.result}"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "Allowed locations (project guardrail)"

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_tags" {
  # Built-in policy: "Require a tag on resources" (assigned once per required tag).
  for_each             = local.required_tag_names
  name                 = "pa-req-${each.value}-${random_string.suffix.result}"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  display_name         = "Require tag '${each.value}' (project guardrail)"

  parameters = jsonencode({
    tagName = { value = each.value }
  })
}
