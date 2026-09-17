output "load_balancer_ip" {
  description = "Public IP of the load balancer fronting the application VMs."
  value       = azurerm_public_ip.lb.ip_address
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_names" {
  value = azurerm_linux_virtual_machine.app[*].name
}
