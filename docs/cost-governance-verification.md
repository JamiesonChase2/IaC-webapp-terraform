# Cost Governance Verification (Azure Budget)

Implements cost governance by provisioning a **monthly Azure Cost Management budget at the Resource Group scope**, with tiered notifications routed to both **email** and an **Azure Monitor Action Group**.

## What was verified

- Budget scope: Resource Group
- Budget name: `bud-ops-ready-webapp-dev-0q3hfc`
- Amount: **$25.00 USD**
- Time grain: **Monthly**
- Time period: `2026-02-01T00:00:00Z` → `2027-02-01T00:00:00Z`
- Notifications (Actual spend): **50%**, **80%**, **100%**
  - `contactEmails`: `<ALERT_EMAIL>`
  - `contactGroups`: `<ACTION_GROUP_RESOURCE_ID>`

## Commands used

Run from `/azure-ops-ready-webapp/infra`:

```bash
BUDGET="$(terraform output -raw budget_name)"
RG="$(terraform output -raw resource_group_name)"

az consumption budget show \
  --resource-group "$RG" \
  --budget-name "$BUDGET" \
  -o jsonc
```

## Implementation notes (Terraform)

- Budget resource: `/azure-ops-ready-webapp/infra/cost.tf`
- Inputs:
  - `budget_amount`, `budget_start_date`, `budget_end_date` in `/azure-ops-ready-webapp/infra/variables.tf`
- Guardrail: Terraform includes a precondition to ensure `budget_end_date` is later than `budget_start_date` (fail fast on misconfiguration).

## Example

```jsonc
{
  "amount": "25.0",
  "category": "Cost",
  "currentSpend": { "amount": "0.0", "unit": "USD" },
  "id": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>/providers/Microsoft.Consumption/budgets/<BUDGET_NAME>",
  "name": "<BUDGET_NAME>",
  "timeGrain": "Monthly",
  "timePeriod": {
    "startDate": "<START_DATE>",
    "endDate": "<END_DATE>"
  },
  "notifications": {
    "actual_GreaterThan_50.000000_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": "50.0",
      "contactEmails": ["<ALERT_EMAIL>"],
      "contactGroups": ["<ACTION_GROUP_RESOURCE_ID>"]
    },
    "actual_GreaterThan_80.000000_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": "80.0",
      "contactEmails": ["<ALERT_EMAIL>"],
      "contactGroups": ["<ACTION_GROUP_RESOURCE_ID>"]
    },
    "actual_GreaterThan_100.000000_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": "100.0",
      "contactEmails": ["<ALERT_EMAIL>"],
      "contactGroups": ["<ACTION_GROUP_RESOURCE_ID>"]
    }
  }
}
```