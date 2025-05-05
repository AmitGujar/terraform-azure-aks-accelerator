variable "aks_agent_pools" {
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

variable "vnet_subnet_id" {
  description = "VNet subnet ID"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}

variable "public_access" {
  description = "Enable public access"
  type        = bool
}

variable "aks_cluster_id" {
  description = "AKS cluster ID"
  type        = string
}
