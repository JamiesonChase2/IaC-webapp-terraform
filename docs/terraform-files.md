# Terraform Files (What Each One Does)

Folder: `/azure-ops-ready-webapp/infra`

- `versions.tf`: Pins Terraform + provider versions (prevents “works on my machine” drift).
- `providers.tf`: Configures providers (for AzureRM, `features {}`; auth typically comes from `az login` via Azure CLI).
- `variables.tf`: Declares inputs (`location`, `owner`, `alert_email`, etc.) with types/defaults/descriptions and validation rules (e.g., email/date format, lowercase location).
- `terraform.tfvars`: Your local values for variables (environment-specific; not committed).
- `locals.tf`: Computed values reused across resources (tags map, name prefixes, required tag list).
- `main.tf`: Core infrastructure resources (RG, Log Analytics, App Service plan/webapp, diagnostics, action group, metric alert) plus a precondition to ensure `location` is included in `allowed_locations`.
- `governance.tf`: Azure Policy assignments (allowed locations + required tags) to enforce guardrails.
- `cost.tf`: Cost governance resources (resource-group monthly budget + notifications) and a precondition to ensure `budget_end_date` is later than `budget_start_date`.
- `outputs.tf`: Values Terraform prints after apply (RG name, webapp URL, LAW IDs) for scripting and verification.
- `.terraform.lock.hcl`: Provider version/checksum lock for repeatable `terraform init`.
- `terraform.tfstate` / `terraform.tfstate.backup`: Terraform state (what’s deployed); not committed.
