variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to use"
}

variable "location" {
  type        = string
  default     = "centralindia"
  description = "Location for the deployment"
}

variable "resource_group_tags" {
  type = map(string)
  default = {
    environment = "uat"
    Exp         = "7"
  }
  description = "Values for the resource group tags"
}

variable "subnet_names" {
  type = list(string)
  default = [
    "cluster_subnet",
    "private_endpoint",
    "jumpbox_subnet",
    "test_subnet"
  ]
  description = "List of multiple subnet names"
}

variable "subnet_prefix_length" {
  type        = number
  description = "The prefix length for the subnets. This number will get added in existing vnet cidr"
  default     = 8
}
variable "vnet_name" {
  type        = string
  default     = "tfgeneratedvnet"
  description = "Name for the virtual network"

}

variable "vnet_cidr" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "CIDR value for the virtual network address space"
}

variable "acr_name" {
  type = string
  # default     = "tfgenaretedacr"
  default     = null
  description = "Name of azure container registry"
}

variable "acr_sku" {
  type        = string
  default     = "Standard"
  description = "The SKU of the Azure Container Registry. Valid values are Standard and Premium."
}

variable "acr_enable_georeplication" {
  type        = bool
  default     = false
  description = "Choice to enable acr georeplication"
}

variable "acr_georeplication_location" {
  type        = string
  default     = "centralindia"
  description = "The location of the georeplication"
}

variable "acr_zone_redundancy_enabled" {
  type        = bool
  default     = false
  description = "Choice to enable acr zone redundancy"
}

variable "acr_admin_enabled_choice" {
  type        = bool
  default     = false
  description = "Choice to enable admin enabled"
}

# this block is deprecated since we will be updating this var realtime based on active subs
# variable "subscription_id" {
#   type        = string
#   description = "The subscription ID to use for the Azure resources."

# }

variable "keyvault_name" {
  type        = string
  default     = null
  description = "Name of the key vault"
}

variable "object_id" {
  type        = string
  default     = ""
  description = "The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault"
  validation {
    condition     = var.keyvault_enabled_for_deployment == false || (var.keyvault_enabled_for_deployment == true && var.object_id != null && var.object_id != "")
    error_message = "object_id is required when keyvault_enabled_for_deployment  is true."
  }
}

variable "tenant_id" {
  type        = string
  default     = ""
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
  validation {
    condition     = var.keyvault_enabled_for_deployment == false || (var.keyvault_enabled_for_deployment == true && var.tenant_id != null && var.tenant_id != "")
    error_message = "tenant_id is required when keyvault_enabled_for_deployment  is true."
  }
}

variable "public_access" {
  type        = bool
  default     = true
  description = "Whether public network access is allowed for key vault and acr"
}

variable "keyvault_enable_rbac_authorization" {
  type        = bool
  default     = false
  description = "Whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions"
}

variable "keyvault_enabled_for_deployment" {
  type        = bool
  default     = false
  description = "Whether Azure Resource Manager is permitted to retrieve secrets from the key vault"
}

variable "keyvault_certificate_permissions" {
  type = list(string)
  default = [
    "Get",
    "List"
  ]
  description = "List of certificate permissions"
}

variable "keyvault_storage_permissions" {
  type = list(string)
  default = [
    "Get",
    "List",
    "Set"
  ]
  description = "List of storage permissions for keyvault"
}

variable "keyvault_key_permissions" {
  type = list(string)
  default = [
    "Get",
    "List",
    "Create"
  ]
  description = "List of key permissions for keyvault"
}

variable "keyvault_secret_permissions" {
  type = list(string)
  default = [
    "Get",
    "List"
  ]
  description = "List of secret permissions for keyvault"
}

variable "keyvault_sku" {
  type        = string
  description = "The sku of the key vault"
  default     = "standard"
}
variable "private_dns_zones" {
  description = "Map of private DNS zones to create"
  type        = map(string)
  default = {
    acr_dns_zone      = "privatelink.azurecr.io"
    keyvault_dns_zone = "privatelink.vaultcore.azure.net"
  }
}

variable "private_endpoint_dns_records" {
  description = "Map of DNS records to create"
  type = map(object({
    name                = string
    zone_name           = string
    resource_group_name = string
    ttl                 = number
    records             = list(string)
  }))
  default = {
    record1 = {
      name                = "acr_name"
      zone_name           = "acr_dns_zone"
      resource_group_name = "rg-terraform"
      ttl                 = 3600
      records             = ["10.0.1.5"]
    },
    dns_data_record = {
      name                = "acr_name.location.data"
      zone_name           = "acr_dns_zone"
      resource_group_name = "rg-terraform"
      ttl                 = 3600
      records             = ["10.0.1.4"]
    },
    keyvault_dns_a_record = {
      name                = "@"
      zone_name           = "keyvault_dns_zone"
      resource_group_name = "rg-terraform"
      ttl                 = 3600
      records             = ["10.0.1.6"]
    }
  }
}
variable "private_dns_zone_link" {
  description = "Map of private DNS zone links to create"
  type        = map(string)
  default = {
    acr_dns_zone      = "acr_dns_zone-link"
    keyvault_dns_zone = "keyvault_dns_zone-link"
  }
}

variable "private_endpoint_name" {
  type = map(string)
  description = "Map of private endpoint names to create"
  default = {
    acr      = "acr-private-endpoint"
    keyvault = "key-vault-private-endpoint"
  }
}

variable "vm_security_rules" {
  description = "List of security rules for the network security group"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "vm_nsg_name" {
  type        = string
  default     = "vm_nsg"
  description = "Name of network security group"
}

variable "vm_ip_allocation_method" {
  type        = string
  default     = "Static"
  description = "Ip allocation method for virtual machine"
}

variable "vm_username" {
  type    = string
  default = "amitgujar"
  description = "Username for the virtual machine"
}

variable "vm_public_ip_name" {
  type        = string
  default     = "pip_jumpserver_001"
  description = "Name of public ip address"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "Size of the virtual machine"
}

variable "vm_name" {
  type    = string
  default = "vmjumpserver"
  description = "Name of the virtual machine"
}

variable "vm_os_disk_name" {
  type    = string
  default = "os-disk-jumpserver"
  description = "Name of the os disk"
}

variable "vm_nic_configuration_name" {
  type    = string
  default = "vm_nic_config"
  description = "Name of the network interface configuration"
}

variable "vm_nic_name" {
  type    = string
  default = "nic_jumpserver_vm"
  description = "Name of the network interface"
}

variable "vm_osdisk_storage_account_type" {
  type    = string
  default = "Premium_LRS"
  description = "Storage account type for the os disk"
}

variable "vm_image_sku_name" {
  type    = string
  default = "18.04-LTS"
  description = "Image sku name for the virtual machine"
}

variable "vm_image_publisher_name" {
  type    = string
  default = "Canonical"
  description = "Image publisher name for the virtual machine"
}

variable "vm_image_offer_name" {
  type    = string
  default = "UbuntuServer"
  description = "Image offer name for the virtual machine"
}

variable "vm_image_version_name" {
  type    = string
  default = "latest"
  description = "Image version name for the virtual machine"
}

variable "vm_nic_private_ip_allocation_method" {
  type        = string
  default     = "Dynamic"
  description = "Private ip allocation method for the virtual machine"
}

variable "public_ssh_key" {
  type    = string
  description = "Public SSH key for the virtual machine"
}

# need to set this value as empty so it's not required
variable "sp_client_id" {
  type        = string
  default     = ""
  description = "The client ID of the service principal"
}

variable "sp_client_secret" {
  type        = string
  default     = ""
  description = "The client secret of the service principal"
}

variable "agent_labels" {
  type = map(string)
  default = {
    "application" = "nginx"
  }
  description = "Labels to be applied to the agent pool"
}

variable "service_principal_based_aks_identity" {
  type        = bool
  default     = false
  description = "Whether to use a service principal or a user assigned identity for the AKS cluster"
}

variable "aks_identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "The type of identity used for the managed cluster. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, an `identity_ids` must be set as well."
}

variable "deploy_k8s" {
  type    = bool
  default = false
  description = "Whether to deploy Kubernetes resources"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.30"
  description = "The version of Kubernetes to use for the managed cluster."
}

variable "aks_dns_prefix" {
  default     = "myaks"
  description = "The DNS prefix for the managed cluster."
  type        = string
}

variable "aks_network_plugin" {
  description = "The network plugin to use for the managed cluster. Possible values are `kubenet` and `azure`. Defaults to `azure`."
  type        = string
  default     = "azure"
}

variable "aks_sku_tier" {
  type    = string
  default = "Free"
  description = "The SKU tier for the managed cluster. Possible values are `Free` and `Paid`. Defaults to `Free`."
}

variable "aks_load_balancer_sku" {
  type        = string
  default     = "standard"
  description = "(Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new kubernetes cluster to be created."
}

variable "aks_network_policy" {
  type        = string
  default     = "azure"
  description = "Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
}

variable "aks_rbac_aad_integration_enabled" {
  type        = bool
  default     = true
  description = "Is Azure Active Directory integration enabled?"
  nullable    = false
}

variable "aks_rbac_aad_admin_group_object_ids" {
  type        = list(string)
  default     = null
  description = "Object ID of groups with admin access."
}

variable "aks_rbac_aad_azure_rbac_enabled" {
  type        = bool
  default     = null
  description = "Is Role Based Access Control based on Azure AD enabled?"
}

variable "aks_rbac_aad_client_app_id" {
  type        = string
  default     = null
  description = "The Client ID of an Azure Active Directory Application."
}

variable "aks_role_based_access_control_enabled" {
  type        = bool
  default     = false
  description = "Enable Role Based Access Control."
}

variable "aks_rbac_aad_tenant_id" {
  type        = string
  default     = null
  description = "The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used."
}

variable "aks_useridentity_name" {
  type    = string
  default = "aksuseridentity"
  description = "Name of the user assigned identity to be used for the AKS cluster."
}

variable "aks_local_account_disabled" {
  description = "Disable local accounts for the AKS cluster."
  type        = bool
  default     = false

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
  default = [
    {
      name                                      = "systempool"
      vm_size                                   = "Standard_B2s"
      auto_scaling_enabled                      = true
      host_encryption_enabled                   = false
      enable_node_public_ip                     = false
      fips_enabled                              = false
      max_count                                 = 2
      max_pods                                  = 30
      min_count                                 = 1
      node_count                                = 1
      node_labels                               = { "env" = "production" }
      only_critical_addons_enabled              = false
      orchestrator_version                      = "1.30"
      os_disk_size_gb                           = 128
      os_disk_type                              = "Managed"
      os_sku                                    = "Ubuntu"
      scale_down_mode                           = "Delete"
      tags                                      = { "purpose" = "system" }
      temporary_name_for_rotation               = "temprotation"
      type                                      = "VirtualMachineScaleSets"
      ultra_ssd_enabled                         = false
      agents_availability_zones                 = []
      agents_pool_max_surge                     = "33%"
      agents_pool_drain_timeout_in_minutes      = 30
      agents_pool_node_soak_duration_in_minutes = 10
    }
  ]
}

variable "aks_agent_pools" {
  description = "List of agent pools to create."
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
  default = [
    {
      name                                      = "agentpool"
      vm_size                                   = "Standard_DS2_v2"
      auto_scaling_enabled                      = true
      host_encryption_enabled                   = false
      enable_node_public_ip                     = false
      fips_enabled                              = false
      max_count                                 = 2
      max_pods                                  = 30
      min_count                                 = 1
      node_count                                = 1
      node_labels                               = { "env" = "production" }
      only_critical_addons_enabled              = false
      orchestrator_version                      = "1.30"
      os_disk_size_gb                           = 128
      os_disk_type                              = "Managed"
      os_sku                                    = "Ubuntu"
      scale_down_mode                           = "Delete"
      tags                                      = { "purpose" = "system" }
      temporary_name_for_rotation               = "temprotation"
      type                                      = "VirtualMachineScaleSets"
      ultra_ssd_enabled                         = false
      agents_availability_zones                 = []
      agents_pool_max_surge                     = "33%"
      agents_pool_drain_timeout_in_minutes      = 30
      agents_pool_node_soak_duration_in_minutes = 10
    }
  ]
}

variable "oidc_issuer_enabled" {
  description = "Enable or Disable the OIDC issuer URL"
  default     = "false"
  type        = bool
}

variable "aks_support_plan" {
  description = "Specifies the support plan which should be used for this Kubernetes Cluster"
  type        = string
  default     = "KubernetesOfficial"
}

variable "aks_api_server_authorized_ip_ranges" {
  description = "Set of authorized IP ranges to allow access to API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "aks_tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {
    environment = "dev"
  }
}