# Azure Ops-Ready Web App (Terraform)

Small end-to-end Azure project focused on **cloud infrastructure**: governance guardrails, monitoring/logging, alerting, and cost governance.

## Repository layout

- `app/`
  - Minimal Node.js app used to generate real traffic and errors (`/healthz` = 200, `/fail` = 500) to validate monitoring + alerts.
- `infra/`
  - Terraform that deploys Azure resources:
    - Resource Group + standard tags
    - App Service (Linux) + Service Plan
    - Log Analytics workspace
    - Diagnostic settings to send App Service logs/metrics to Log Analytics
    - Metric alert on HTTP 5xx routed to an Action Group (email)
    - Azure Policy guardrails at the Resource Group scope (allowed regions + required tags)
    - Monthly Azure budget at the Resource Group scope (tiered notifications)
- `docs/`
  - Evidence + verification notes:
    - `governance-verification.md`
    - `ops-verification.md`
    - `cost-governance-verification.md`
    - `terraform-files.md`

## Quick start (infra)

From `infra/`:

```bash
terraform init
terraform plan
terraform apply
```

## Verification

Follow the docs in `docs/` to reproduce evidence for:
- governance (policy deny tests)
- ops (Log Analytics logs + metric alert email)
- cost governance (budget existence + notifications)

