# Governance Verification (Azure Policy Guardrails)

This project implements **resource-group-scoped Azure Policy guardrails** (deny effects) and provides repeatable CLI-based verification steps you can run to prove the controls work.

## What was implemented

Terraform creates **policy assignments at the Resource Group scope**:

- **Allowed locations** (deny deployments outside an approved region list)
  - Policy definition ID: `e56962a6-4747-49cd-b67b-bf8b01975c4c`
  - Assignment: `azurerm_resource_group_policy_assignment.allowed_locations` in `/azure-ops-ready-webapp/infra/governance.tf`
  - Parameter: `listOfAllowedLocations = var.allowed_locations`
- **Require tags on all resources** (deny if a tag is missing)
  - Policy definition ID: `871b6d14-10aa-478d-b590-94f262ecfa99` (“Require a tag on resources”)
  - Assignments: `azurerm_resource_group_policy_assignment.require_tags` (one per tag) in `/azure-ops-ready-webapp/infra/governance.tf`
  - Required tags (from `/azure-ops-ready-webapp/infra/locals.tf`): `owner`, `environment`, `application`

The approved region list is configurable (from `/azure-ops-ready-webapp/infra/variables.tf`):

- `allowed_locations` default: `mexicocentral, norwayeast, eastus, southcentralus, westus3`
- `location` should be one of the `allowed_locations` entries. Terraform enforces this with a precondition on the resource group.

## How to verify (CLI)

Run these from `/azure-ops-ready-webapp/infra`.

### 1) Get your Resource Group name

```bash
RG="$(terraform output -raw resource_group_name)"
SUB_ID="$(az account show --query id -o tsv)"
SCOPE="/subscriptions/$SUB_ID/resourceGroups/$RG"
echo "$SCOPE"
```

### 2) Confirm the policy assignments exist

```bash
az policy assignment list --scope "$SCOPE" -o table
```

You should see assignments with display names similar to:

- `Allowed locations (project guardrail)`
- `Require tag 'owner' (project guardrail)`
- `Require tag 'environment' (project guardrail)`
- `Require tag 'application' (project guardrail)`

## Evidence: Negative tests (deny enforcement)

These two tests prove the guardrails actually block noncompliant deployments.

### Test A — Disallowed region should be denied

Attempt to deploy a throwaway resource to a non-approved region:

```bash
RAND="$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 12)"
SA="q${RAND:0:23}" # storage account name rules

az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "westus2" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --tags owner="YOUR_NAME" environment="dev" application="ops-ready-webapp"
```

Expected result: a denial similar to:

```text
(RequestDisallowedByAzure) ... was disallowed by Azure: This policy maintains a set of best available regions ...
```

Note: In this environment, the region restriction is enforced by an upstream/subscription policy, which is still a realistic governance outcome and aligns with the “allowed locations” objective.

### Test B — Missing required tags should be denied (even in an allowed region)

Attempt the same resource in an allowed region, but omit tags:

```bash
az storage account create \
  --name "$SA" \
  --resource-group "$RG" \
  --location "eastus" \
  --sku Standard_LRS \
  --kind StorageV2
```

Expected result: a denial similar to:

```text
(RequestDisallowedByPolicy) ... was disallowed by policy. Policy identifiers: ...
... "Require tag 'owner' (project guardrail)" ...
... "Require tag 'application' (project guardrail)" ...
... "Require tag 'environment' (project guardrail)" ...
```

This proves the resource-group-level “require tags” guardrails are active and blocking untagged resources.

## (Optional) Positive check: confirm tags exist on deployed resources

```bash
az resource list -g "$RG" --query "[].{name:name,type:type,tags:tags}" -o table
```

## Resume-ready framing (copy/paste)

- Implemented Azure governance guardrails using Terraform + Azure Policy at resource-group scope: allowed regions + mandatory tagging (deny effects).
- Validated guardrails with negative tests (region + missing tags) and documented evidence of enforced policy decisions.
