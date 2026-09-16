# Azure DevOps Labs

Runnable companion code for the Azure articles on [Dumka Esaenwi's technical blog](https://dumkaesaenwi.pages.dev). Each folder maps to one article — copy, adapt the placeholder values (`<sub-id>`, resource group names, etc.), and run.

## Contents

| Folder | Article |
| --- | --- |
| [`terraform/`](terraform) | Terraform on Azure: Infrastructure as Code with the azurerm Provider — VNet + VM + Load Balancer module |
| [`github-actions/`](github-actions) | Building a CI/CD Pipeline to AKS with GitHub Actions — OIDC-authenticated build & deploy |
| [`kubernetes/`](kubernetes) | Kubernetes on Azure: AKS vs. Self-Managed — StorageClass and cluster provisioning |
| [`scripts/`](scripts) | Cost Optimization on Azure — Spot VM creation and budget alert setup |
| [`monitoring/`](monitoring) | Monitoring and Observability on Azure — KQL queries and scheduled alert rules |

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`), logged in: `az login`
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- `kubectl`, for the Kubernetes examples

## Usage

Each folder is self-contained. See the comments at the top of each file for the exact `az`/`terraform`/`kubectl` command to run it. None of this provisions anything on its own — it's reference code to run deliberately against your own subscription.
