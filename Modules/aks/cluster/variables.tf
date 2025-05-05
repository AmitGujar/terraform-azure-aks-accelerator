# variable "enable_auto_scaling" {
#   description = "Enable auto-scaling for the node pool"
#   type        = bool
#   default     = true
# }

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "my-aks-cluster"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

# variable "agents_proximity_placement_group_id" {
#   description = "Proximity placement group ID for agent nodes"
#   type        = string
#   default     = "[]"
# }



# variable "agents_tags" {
#   description = "Tags for the agent nodes"
#   type        = map(string)
#   default     = {}
# }

variable "vnet_subnet_id" {
  description = "VNet subnet ID"
  type        = string
}

# variable "agents_availability_zones" {
#   description = "Availability zones for the agent nodes"
#   type        = list(string)
#   default     = []
# }

# variable "agents_pool_max_surge" {
#   description = "Maximum surge for the agent pool"
#   type        = string
#   default     = "33%"
# }

# variable "agents_pool_drain_timeout_in_minutes" {
#   description = "Drain timeout in minutes for the agent pool"
#   type        = number
#   default     = 30
# }

# variable "agents_pool_node_soak_duration_in_minutes" {
#   description = "Node soak duration in minutes for the agent pool"
#   type        = number
#   default     = 10
# }

variable "sp_client_id" {
  description = "Service principal client ID"
  type        = string
}

variable "sp_client_secret" {
  description = "Service principal client secret"
  type        = string
}

variable "public_access" {
  description = "Enable public access"
  type        = bool
}

variable "aks_service_cidr" {
  description = "Service CIDR"
  type        = string
}

variable "aks_dns_service_ip" {
  description = "DNS service IP"
  type        = string

}

variable "aks_sku_tier" {
  type = string
  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.aks_sku_tier)
    error_message = "Invalid SKU. Valid values are Standard, and Premium. Free is default"
  }
}

variable "aks_load_balancer_sku" {
  type        = string
  description = "(Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new kubernetes cluster to be created."

  validation {
    condition     = contains(["basic", "standard"], var.aks_load_balancer_sku)
    error_message = "Possible values are `basic` and `standard`"
  }
}


variable "aks_network_policy" {
  type = string
  validation {
    condition     = contains(["calico", "azure"], var.aks_network_policy)
    error_message = "Invalid network policy. Supported values are calico and azure."
  }
  description = " Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
}

variable "aks_rbac_aad_integration_enabled" {
  type        = bool
  description = "Is Azure Active Directory integration enabled?"
  nullable    = false
}

variable "aks_rbac_aad_admin_group_object_ids" {
  type        = list(string)
  description = "Object ID of groups with admin access."
}

variable "aks_rbac_aad_azure_rbac_enabled" {
  type        = bool
  description = "Is Role Based Access Control based on Azure AD enabled?"
}

variable "aks_rbac_aad_client_app_id" {
  type        = string
  description = "The Client ID of an Azure Active Directory Application."
}

variable "aks_role_based_access_control_enabled" {
  type        = bool
  description = "Enable Role Based Access Control."
  nullable    = false
}

# variable "identity_ids" {
#   type        = list(string)
#   default     = null
#   description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster."
# }

variable "aks_identity_type" {
  type        = string
  description = "The type of identity used for the managed cluster. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, an `identity_ids` must be set as well."

  validation {
    condition     = var.aks_identity_type == "SystemAssigned" || var.aks_identity_type == "UserAssigned" || var.aks_identity_type == ""
    error_message = "`identity_type`'s possible values are `SystemAssigned` and `UserAssigned`"
  }
}

variable "aks_support_plan" {
  type = string
  validation {
    condition     = var.aks_support_plan == "KubernetesOfficial" || var.aks_support_plan == "AKSLongTermSupport"
    error_message = "value must be either KubernetesOfficial or AKSLongTermSupport"
  }
}

variable "aks_rbac_aad_tenant_id" {
  type        = string
  description = "The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used."
}

variable "aks_useridentity_name" {
  type = string
}

variable "service_principal_based_aks_identity" {
  type        = bool
  description = "Is the identity based on a service principal"
}

variable "aks_api_server_authorized_ip_ranges" {
  type = list(string)
}

# variable "agents_max_count" {
#   description = "Maximum number of nodes in the agent pool"
#   type        = number
#   default     = 2

# }

# variable "agents_min_count" {
#   description = "Minimum number of nodes in the agent pool"
#   type        = number
#   default     = 1

# }

variable "aks_local_account_disabled" {
  description = "Disable local account"
  type        = bool
}

variable "aks_system_pools" {
  description = "List of system pools to create."
  type = list(object({
    name                                      = string
    vm_size                                   = string
    auto_scaling_enabled                      = bool
    host_encryption_enabled                   = bool
    enable_node_public_ip                     = bool
    fips_enabled                              = bool
    max_count                                 = number
    max_pods                                  = number
    min_count                                 = number
    node_count                                = number
    node_labels                               = map(string)
    only_critical_addons_enabled              = bool
    orchestrator_version                      = string
    os_disk_size_gb                           = number
    os_disk_type                              = string
    os_sku                                    = string
    scale_down_mode                           = string
    tags                                      = map(string)
    temporary_name_for_rotation               = string
    type                                      = string
    ultra_ssd_enabled                         = bool
    agents_availability_zones                 = list(string)
    agents_pool_max_surge                     = string
    agents_pool_drain_timeout_in_minutes      = number
    agents_pool_node_soak_duration_in_minutes = number
  }))
}

variable "aks_network_plugin" {
  description = "Network plugin to use"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "oidc_issuer_enabled" {
  type = bool
}

variable "keyvault_enabled_for_deployment" {
  type = bool
}

variable "aks_tags" {
  type        = map(string)
  description = "tags for the aks cluster"
}