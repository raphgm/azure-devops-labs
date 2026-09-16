#!/usr/bin/env bash
# From: "Cost Optimization on Azure: Reservations, Spot VMs, and Budgets That Actually Alert"
# Creates a Spot VM for interruption-tolerant workloads (batch, CI agents).
set -euo pipefail

az vm create \
  --resource-group batch-rg \
  --name batch-worker \
  --priority Spot \
  --eviction-policy Delete \
  --max-price -1 \
  --image Ubuntu2204

# Poll for an eviction notice from inside the VM (gives ~30s warning):
#   curl -H Metadata:true "http://169.254.169.254/metadata/scheduledevents?api-version=2020-07-01"
