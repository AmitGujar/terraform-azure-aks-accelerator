output "aks_principal_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_user_assigned[0].principal_id : azurerm_kubernetes_cluster.tf_managed_aks.kubelet_identity[0].object_id
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.tf_managed_aks.id
}

output "kubelet_identity_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks_user_assigned[0].id : null
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.tf_managed_aks.name
}
