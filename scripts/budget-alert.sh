#!/usr/bin/env bash
# From: "Cost Optimization on Azure: Reservations, Spot VMs, and Budgets That Actually Alert"
# Creates a monthly budget with both an actual-spend and a forecasted-spend alert.
set -euo pipefail

az consumption budget create \
  --budget-name monthly-prod-budget \
  --amount 5000 \
  --time-grain Monthly \
  --category Cost \
  --notifications '{
    "Actual_GreaterThan_80_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": 80,
      "contactEmails": ["platform-team@company.com"]
    },
    "Forecasted_GreaterThan_100_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": 100,
      "thresholdType": "Forecasted",
      "contactEmails": ["platform-team@company.com"]
    }
  }'
