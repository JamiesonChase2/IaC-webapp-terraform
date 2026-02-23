# Terraform Files (What Each One Does)

Folder: `/azure-ops-ready-webapp/infra`

- `versions.tf`: Pins Terraform + provider versions.
- `providers.tf`: Configures providers.
- `variables.tf`: Declares inputs (`location`, `owner`, `alert_email`, etc.) with types/defaults/descriptions and validation rules.
- `terraform.tfvars`: Your local values for variables.
- `locals.tf`: Computed values reused across resources (tags map, name prefixes, required tag list).
- `main.tf`: Core infrastructure resources (RG, Log Analytics, App Service plan/webapp, diagnostics, action group, metric alert).
- `governance.tf`: Azure Policy assignments (allowed locations + required tags) to enforce guardrails.
- `cost.tf`: Cost governance resources (resource group monthly budget + notifications).
- `outputs.tf`: Values Terraform prints after apply (RG name, webapp URL, LAW IDs) for scripting and verification.
- `.terraform.lock.hcl`: Provider version/checksum lock.
- `terraform.tfstate` / `terraform.tfstate.backup`: Terraform state.
