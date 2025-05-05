resource "azurerm_role_assignment" "acrpull" {
  principal_id         = var.aks_principal_id
  role_definition_name = "AcrPull"
  scope                = var.identity_scope

  lifecycle {
    ignore_changes = all
  }
}

