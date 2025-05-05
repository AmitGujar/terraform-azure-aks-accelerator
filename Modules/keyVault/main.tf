resource "random_integer" "random" {
  min = 10
  max = 99
}

resource "azurerm_key_vault" "key_vault" {
  name                          = coalesce(var.keyvault_name, "${var.resource_group_name}kv${random_integer.random.result}")
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku_name                      = var.keyvault_sku_name
  tenant_id                     = var.tenant_id
  enable_rbac_authorization     = var.keyvault_enable_rbac_authorization
  public_network_access_enabled = var.keyvault_public_network_access_enabled
  enabled_for_deployment        = var.keyvault_enabled_for_deployment

  dynamic "network_acls" {
    for_each = var.keyvault_public_network_access_enabled ? [1] : []
    content {
      default_action = "Deny"
      bypass         = "AzureServices"
    }
  }
}

resource "azurerm_key_vault_access_policy" "kv_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  key_permissions = var.keyvault_key_permissions

  certificate_permissions = var.keyvault_certificate_permissions

  secret_permissions = var.keyvault_secret_permissions

  storage_permissions = var.keyvault_storage_permissions
}
