resource "azurerm_user_assigned_identity" "aks_user_assigned" {
  count               = var.aks_identity_type == "UserAssigned" ? 1 : 0
  name                = var.aks_useridentity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

# kept this role assignment in aks module because ckuster creation is dependent on this
resource "azurerm_role_assignment" "kubelet_identity_operator" {
  count                = var.aks_identity_type == "UserAssigned" ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.aks_user_assigned[0].principal_id
  role_definition_name = "Managed Identity Operator"
  scope                = azurerm_user_assigned_identity.aks_user_assigned[0].id
}

resource "azurerm_kubernetes_cluster" "tf_managed_aks" {
  name                    = var.aks_cluster_name
  resource_group_name     = var.resource_group_name
  location                = var.location
  node_resource_group     = "${var.resource_group_name}-node-group"
  dns_prefix              = var.aks_dns_prefix
  private_cluster_enabled = var.public_access == false
  sku_tier                = var.aks_sku_tier
  local_account_disabled  = var.aks_local_account_disabled
  kubernetes_version      = var.kubernetes_version
  oidc_issuer_enabled     = var.oidc_issuer_enabled
  support_plan            = var.aks_support_plan
  tags                    = var.aks_tags
  # csi drivers will get installed only if keyvault is deployed
  dynamic "key_vault_secrets_provider" {
    for_each = var.keyvault_enabled_for_deployment ? [1] : []
    content {
      secret_rotation_enabled = "true"
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.public_access ? [] : [1]
    content {
      authorized_ip_ranges = var.aks_api_server_authorized_ip_ranges
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = !var.aks_local_account_disabled && var.aks_role_based_access_control_enabled && var.aks_rbac_aad_integration_enabled ? ["rbac"] : []

    content {
      admin_group_object_ids = var.aks_rbac_aad_admin_group_object_ids
      azure_rbac_enabled     = var.aks_rbac_aad_azure_rbac_enabled
      tenant_id              = var.aks_rbac_aad_tenant_id
    }
  }
  dynamic "service_principal" {
    # for_each = var.sp_client_id != "" && var.sp_client_secret != "" ? ["service_principal"] : []
    for_each = var.service_principal_based_aks_identity ? ["service_principal"] : []
    content {
      client_id     = var.sp_client_id
      client_secret = var.sp_client_secret
    }
  }

  dynamic "identity" {
    #for_each = var.sp_client_id == "" || var.sp_client_secret == "" ? ["identity"] : []
    for_each = var.service_principal_based_aks_identity ? [] : ["identity"]
    content {
      type         = var.aks_identity_type
      identity_ids = var.aks_identity_type == "UserAssigned" ? [azurerm_user_assigned_identity.aks_user_assigned[0].id] : null
    }
  }
  network_profile {
    network_plugin    = var.aks_network_plugin
    service_cidr      = var.aks_service_cidr
    dns_service_ip    = var.aks_dns_service_ip
    load_balancer_sku = var.aks_load_balancer_sku
    network_policy    = var.aks_network_policy
  }

  dynamic "kubelet_identity" {
    for_each = var.aks_identity_type == "UserAssigned" ? ["kubelet_identity"] : []

    content {
      client_id                 = azurerm_user_assigned_identity.aks_user_assigned[0].client_id
      object_id                 = azurerm_user_assigned_identity.aks_user_assigned[0].principal_id
      user_assigned_identity_id = azurerm_user_assigned_identity.aks_user_assigned[0].id
    }
  }

  dynamic "default_node_pool" {
    for_each = { for i, pool in var.aks_system_pools : i => pool }

    content {
      name                         = default_node_pool.value.name
      vm_size                      = default_node_pool.value.vm_size
      auto_scaling_enabled         = default_node_pool.value.auto_scaling_enabled
      host_encryption_enabled      = default_node_pool.value.host_encryption_enabled
      node_public_ip_enabled       = var.public_access ? default_node_pool.value.enable_node_public_ip : false
      fips_enabled                 = default_node_pool.value.fips_enabled
      max_count                    = default_node_pool.value.auto_scaling_enabled ? default_node_pool.value.max_count : null
      max_pods                     = default_node_pool.value.max_pods
      min_count                    = default_node_pool.value.auto_scaling_enabled ? default_node_pool.value.min_count : null
      node_count                   = default_node_pool.value.node_count
      node_labels                  = default_node_pool.value.node_labels
      only_critical_addons_enabled = default_node_pool.value.only_critical_addons_enabled
      orchestrator_version         = default_node_pool.value.orchestrator_version
      os_disk_size_gb              = default_node_pool.value.os_disk_size_gb
      os_disk_type                 = default_node_pool.value.os_disk_type
      os_sku                       = default_node_pool.value.os_sku
      scale_down_mode              = default_node_pool.value.scale_down_mode
      tags                         = merge(var.aks_tags, default_node_pool.value.tags)
      temporary_name_for_rotation  = default_node_pool.value.temporary_name_for_rotation
      type                         = default_node_pool.value.type
      ultra_ssd_enabled            = default_node_pool.value.ultra_ssd_enabled
      vnet_subnet_id               = var.vnet_subnet_id
      zones                        = default_node_pool.value.agents_availability_zones

      dynamic "upgrade_settings" {
        for_each = default_node_pool.value.agents_pool_max_surge == null ? [] : ["upgrade_settings"]

        content {
          max_surge                     = default_node_pool.value.agents_pool_max_surge
          drain_timeout_in_minutes      = default_node_pool.value.agents_pool_drain_timeout_in_minutes
          node_soak_duration_in_minutes = default_node_pool.value.agents_pool_node_soak_duration_in_minutes
        }
      }
    }
  }
  lifecycle {
    precondition {
      condition     = (var.sp_client_id != "" && var.sp_client_secret != "") || (var.aks_identity_type != "")
      error_message = "Either `client_id` and `client_secret` or `identity_type` must be set."
    }
  }

  depends_on = [azurerm_role_assignment.kubelet_identity_operator]
}
