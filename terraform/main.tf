# Terraform on Azure: VNet + VM + Load Balancer
# From: "Terraform on Azure: Infrastructure as Code with the azurerm Provider"
#
# Usage:
#   terraform init
#   terraform plan -var-file=environments/staging.tfvars
#   terraform apply -var-file=environments/staging.tfvars
#
# Auth: az login, or set ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID /
# ARM_SUBSCRIPTION_ID for CI, or OIDC federation (see ../github-actions/deploy-aks.yml).

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "azure-devops-labs"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "app-rg-${var.environment}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "app-vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "app" {
  name                = "app-nsg-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  security_rule {
    name                       = "allow-lb-probe"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_public_ip" "lb" {
  name                = "app-lb-ip-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_lb" "public" {
  name                = "app-lb-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "app" {
  name            = "app-backend-pool"
  loadbalancer_id = azurerm_lb.public.id
}

resource "azurerm_lb_probe" "app" {
  name            = "http-health-probe"
  loadbalancer_id = azurerm_lb.public.id
  protocol        = "Http"
  port            = 8080
  request_path    = "/health"
}

resource "azurerm_lb_rule" "app" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.public.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "public-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.app.id
}

resource "azurerm_network_interface" "app" {
  count               = var.vm_count
  name                = "app-nic-${var.environment}-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "app" {
  count                   = var.vm_count
  network_interface_id   = azurerm_network_interface.app[count.index].id
  ip_configuration_name  = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app.id
}

resource "azurerm_linux_virtual_machine" "app" {
  count                 = var.vm_count
  name                  = "app-vm-${var.environment}-${count.index}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.app[count.index].id]
  tags                  = local.tags

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.admin_ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  # Installs Docker and runs the sample app from ../app on boot.
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update && apt-get install -y docker.io
    systemctl enable --now docker
  EOF
  )
}
