resource "azurerm_kubernetes_cluster_node_pool" "agentpools" {
  for_each = { for i, pool in var.aks_agent_pools : i => pool }

  name                    = each.value.name
  kubernetes_cluster_id   = var.aks_cluster_id
  vm_size                 = each.value.vm_size
  auto_scaling_enabled    = each.value.auto_scaling_enabled
  host_encryption_enabled = each.value.host_encryption_enabled
  node_public_ip_enabled  = var.public_access ? each.value.enable_node_public_ip : false
  fips_enabled            = each.value.fips_enabled
  max_count               = each.value.auto_scaling_enabled ? each.value.max_count : null
  max_pods                = each.value.max_pods
  min_count               = each.value.auto_scaling_enabled ? each.value.min_count : null
  node_count              = each.value.node_count
  node_labels             = each.value.node_labels
  orchestrator_version    = each.value.orchestrator_version
  os_disk_size_gb         = each.value.os_disk_size_gb
  os_disk_type            = each.value.os_disk_type
  os_sku                  = each.value.os_sku
  scale_down_mode         = each.value.scale_down_mode
  tags                    = merge(var.tags, each.value.tags)
  ultra_ssd_enabled       = each.value.ultra_ssd_enabled
  vnet_subnet_id          = var.vnet_subnet_id
  zones                   = each.value.agents_availability_zones

  dynamic "upgrade_settings" {
    for_each = each.value.agents_pool_max_surge == null ? [] : ["upgrade_settings"]

    content {
      max_surge                     = each.value.agents_pool_max_surge
      drain_timeout_in_minutes      = each.value.agents_pool_drain_timeout_in_minutes
      node_soak_duration_in_minutes = each.value.agents_pool_node_soak_duration_in_minutes
    }
  }
}
