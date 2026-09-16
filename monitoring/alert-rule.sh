#!/usr/bin/env bash
# From: "Monitoring and Observability on Azure with Azure Monitor and Application Insights"
# Wires error-rate.kql into a scheduled alert rule.
set -euo pipefail

az monitor scheduled-query create \
  --name "api-error-rate-high" \
  --resource-group prod-rg \
  --scopes /subscriptions/<sub-id>/resourceGroups/prod-rg/providers/microsoft.insights/components/api-insights \
  --condition "count 'requests' > 0" \
  --condition-query "requests | where success == false | summarize count() by bin(timestamp, 5m)" \
  --window-size 5m \
  --evaluation-frequency 5m \
  --severity 2
