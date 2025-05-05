# this code will be updated in future

output "aks_principal_id" {
  value       = module.aks.aks_principal_id
  description = "Value of the AKS principal id"
}

output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Value of the resource group name"
}

output "aks_cluster_name" {
  value       = module.aks.aks_cluster_name
  description = "Name of the AKS cluster"
}

output "jumpserver_ip" {
  value       = var.public_access ? null : module.virtualMachine[0].jumpserver_ip
  description = "IP address of the jump server"
}

output "jumpserver_username" {
  value       = var.public_access ? null : module.virtualMachine[0].vm_username
  description = "Username of the jump server"
}
