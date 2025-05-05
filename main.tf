module "resource_group" {
  source              = "./Modules/resourceGroup"
  resource_group_name = var.resource_group_name
  location            = var.location
  resource_group_tags = var.resource_group_tags
}

module "virtual_network" {
  source                           = "./Modules/virtualNetwork"
  address_prefixes_to_subnet_names = var.subnet_names
  resource_group_name              = module.resource_group.resource_group_name
  vnet_name                        = var.vnet_name
  vnet_cidr                        = var.vnet_cidr
  location                         = var.location
  subnet_prefix_length             = var.subnet_prefix_length
  depends_on                       = [module.resource_group]
}

module "containerRegistry" {
  source                            = "./Modules/containerRegistry"
  resource_group_name               = module.resource_group.resource_group_name
  location                          = var.location
  acr_name                          = var.acr_name
  acr_sku                           = var.acr_sku
  acr_enable_georeplication         = var.acr_enable_georeplication
  acr_georeplication_location       = var.acr_georeplication_location
  acr_zone_redundancy_enabled       = var.acr_zone_redundancy_enabled
  acr_admin_enabled_choice          = var.acr_admin_enabled_choice
  acr_public_network_access_enabled = var.public_access
  public_access                     = var.public_access
  depends_on                        = [module.virtual_network]
}

module "keyVault" {
  count                                  = var.keyvault_enabled_for_deployment ? 1 : 0
  source                                 = "./Modules/keyVault"
  keyvault_name                          = var.keyvault_name
  resource_group_name                    = module.resource_group.resource_group_name
  location                               = var.location
  object_id                              = var.object_id
  tenant_id                              = var.tenant_id
  keyvault_sku_name                      = var.keyvault_sku
  keyvault_public_network_access_enabled = var.public_access
  keyvault_enable_rbac_authorization     = var.keyvault_enable_rbac_authorization
  keyvault_enabled_for_deployment        = var.keyvault_enabled_for_deployment
  keyvault_certificate_permissions       = var.keyvault_certificate_permissions
  keyvault_storage_permissions           = var.keyvault_storage_permissions
  keyvault_key_permissions               = var.keyvault_key_permissions
  keyvault_secret_permissions            = var.keyvault_secret_permissions
  depends_on                             = [module.virtual_network]
}

module "privateEndpoints" {
  count  = var.public_access ? 0 : 1
  source = "./Modules/privateEndpoint"
  private_dns_zone = {
    acr_dns_zone      = "${var.private_dns_zones["acr_dns_zone"]}"
    keyvault_dns_zone = "${var.private_dns_zones["keyvault_dns_zone"]}"
  }
  resource_group_name          = module.resource_group.resource_group_name
  location                     = var.location
  private_dns_zone_link        = var.private_dns_zone_link
  virtual_network_id           = module.virtual_network.virtual_network_id
  private_endpoint_dns_records = var.private_endpoint_dns_records
  acr_id                       = module.containerRegistry.acr_id
  acr_name                     = module.containerRegistry.acr_name
  keyvault_id                  = module.keyVault[0].keyvault_id
  keyvault_name                = module.keyVault[0].keyvault_name
  endpoint_subnet_id           = module.virtual_network.subnet_ids["private_endpoint"]
  private_endpoint_name        = var.private_endpoint_name
}

module "virtualMachine" {
  count                               = var.public_access ? 0 : 1
  source                              = "./Modules/virtualMachine"
  resource_group_name                 = module.resource_group.resource_group_name
  location                            = var.location
  vm_nsg_name                         = var.vm_nsg_name
  vm_ip_allocation_method             = var.vm_ip_allocation_method
  vm_nic_private_ip_allocation_method = var.vm_nic_private_ip_allocation_method
  vm_username                         = var.vm_username
  vm_public_ip_name                   = var.vm_public_ip_name
  vm_size                             = var.vm_size
  vm_name                             = var.vm_name
  public_ssh_key                      = var.public_ssh_key
  vm_image_publisher_name             = var.vm_image_publisher_name
  vm_image_offer_name                 = var.vm_image_offer_name
  vm_image_sku_name                   = var.vm_image_sku_name
  vm_image_version_name               = var.vm_image_version_name
  vm_security_rules                   = var.vm_security_rules
  vm_os_disk_name                     = var.vm_os_disk_name
  vm_nic_configuration_name           = var.vm_nic_configuration_name
  vm_nic_name                         = var.vm_nic_name
  vm_osdisk_storage_account_type      = var.vm_osdisk_storage_account_type
  vm_subnet_id                        = module.virtual_network.subnet_ids["jumpbox_subnet"]
}

locals {
  service_cidr = cidrsubnet(var.vnet_cidr[0], var.subnet_prefix_length, module.virtual_network.last_subnet_index + 1)
}
module "aks" {
  source                                = "./Modules/aks/cluster"
  sp_client_id                          = var.sp_client_id
  sp_client_secret                      = var.sp_client_secret
  resource_group_name                   = module.resource_group.resource_group_name
  location                              = var.location
  vnet_subnet_id                        = module.virtual_network.subnet_ids["cluster_subnet"]
  public_access                         = var.public_access
  aks_dns_service_ip                    = cidrhost(local.service_cidr, 10)
  aks_service_cidr                      = local.service_cidr
  service_principal_based_aks_identity  = var.service_principal_based_aks_identity
  aks_identity_type                     = var.aks_identity_type
  aks_local_account_disabled            = var.aks_local_account_disabled
  aks_system_pools                      = var.aks_system_pools
  aks_useridentity_name                 = var.aks_useridentity_name
  aks_rbac_aad_tenant_id                = var.aks_rbac_aad_tenant_id
  kubernetes_version                    = var.kubernetes_version
  aks_network_plugin                    = var.aks_network_plugin
  aks_dns_prefix                        = var.aks_dns_prefix
  aks_sku_tier                          = var.aks_sku_tier
  aks_load_balancer_sku                 = var.aks_load_balancer_sku
  aks_network_policy                    = var.aks_network_policy
  aks_rbac_aad_integration_enabled      = var.aks_rbac_aad_integration_enabled
  aks_rbac_aad_admin_group_object_ids   = var.aks_rbac_aad_admin_group_object_ids
  aks_rbac_aad_azure_rbac_enabled       = var.aks_rbac_aad_azure_rbac_enabled
  aks_rbac_aad_client_app_id            = var.aks_rbac_aad_client_app_id
  aks_role_based_access_control_enabled = var.aks_role_based_access_control_enabled
  aks_support_plan                      = var.aks_support_plan
  oidc_issuer_enabled                   = var.oidc_issuer_enabled
  aks_api_server_authorized_ip_ranges   = var.aks_api_server_authorized_ip_ranges
  keyvault_enabled_for_deployment       = var.keyvault_enabled_for_deployment
  aks_tags                              = var.aks_tags
}

module "agenpool" {
  source          = "./Modules/aks/agentpool"
  vnet_subnet_id  = module.virtual_network.subnet_ids["cluster_subnet"]
  public_access   = var.public_access
  aks_cluster_id  = module.aks.aks_cluster_id
  aks_agent_pools = var.aks_agent_pools
}

module "roles" {
  source              = "./Modules/roles"
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  aks_principal_id    = module.aks.aks_principal_id
  identity_scope      = module.containerRegistry.acr_id
}
