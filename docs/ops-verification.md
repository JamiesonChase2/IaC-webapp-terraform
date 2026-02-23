# Ops Verification (Monitoring, Logs, Alerting)

Captures proof that the deployed App Service is healthy, emits logs to Log Analytics, and has a working alert path for HTTP 5xx errors.

Run commands from `/azure-ops-ready-webapp/infra`.

## 1) App endpoints (functional check)

```bash
URL="$(terraform output -raw webapp_url)"
curl -s -o /dev/null -w "%{http_code}\n" "$URL/healthz"
curl -s -o /dev/null -w "%{http_code}\n" "$URL/fail"
```

Expected:
- `/healthz` returns `200`
- `/fail` returns `500` (used to drive the Http5xx metric)

Evidence (2026-02-23):

```text
200
500
```

```bash
for i in {1..10}; do curl -s -o /dev/null -w "%{http_code}\n" "$URL/healthz"; sleep 1; done
```

## 2) Diagnostics are enabled to Log Analytics

Confirm a diagnostic setting exists for the web app resource:

```bash
APPID="$(terraform output -raw webapp_resource_id)"
az monitor diagnostic-settings list --resource "$APPID" -o table
```

## 3) Log Analytics query proof (AppServiceHTTPLogs)

Query HTTP logs in the workspace and summarize totals + 5xx errors:

```bash
LAW="$(terraform output -raw log_analytics_workspace_customer_id)"
APPID="$(terraform output -raw webapp_resource_id)"

az monitor log-analytics query --workspace "$LAW" --analytics-query "
AppServiceHTTPLogs
| where TimeGenerated > ago(60m)
| where tolower(_ResourceId) == tolower('$APPID')
| summarize Total=count(), Errors=countif(ScStatus >= 500)
" -o table
```

```text
Errors    TableName      Total
--------  -------------  -------
0         PrimaryResult  14
```

## 4) Alert proof (HTTP 5xx → email)

Terraform defines a metric alert on the App Service metric `Http5xx` with a threshold `> 0` over a 5-minute window, connected to an email Action Group.

Evidence (2026-02-23):
- Triggered `/fail` to generate 5xx responses.
- Received the alert email (Action Group notification), confirming end-to-end alerting works.
