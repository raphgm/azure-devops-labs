#!/usr/bin/env bash
# From: "Kubernetes on Azure: AKS vs. Self-Managed, and When to Choose Which"
# Provisions a Standard-tier AKS cluster with managed identity and monitoring enabled.
set -euo pipefail

az aks create \
  --resource-group prod-rg \
  --name prod-aks \
  --tier standard \
  --node-count 3 \
  --node-vm-size Standard_D4s_v5 \
  --enable-managed-identity \
  --network-plugin azure \
  --generate-ssh-keys \
  --enable-addons monitoring

# Optional: add a Spot node pool for interruption-tolerant workloads.
az aks nodepool add \
  --resource-group prod-rg \
  --cluster-name prod-aks \
  --name spotpool \
  --priority Spot \
  --eviction-policy Delete \
  --spot-max-price -1 \
  --enable-cluster-autoscaler \
  --min-count 0 \
  --max-count 10
