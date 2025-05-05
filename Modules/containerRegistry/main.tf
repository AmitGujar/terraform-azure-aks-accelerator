resource "random_integer" "random" {
  min = 10
  max = 99
}

resource "azurerm_container_registry" "acr" {
  name                          = coalesce(var.acr_name, "acr${var.location}${random_integer.random.result}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.public_access ? "Standard" : "Premium"
  admin_enabled                 = var.acr_admin_enabled_choice
  public_network_access_enabled = var.acr_public_network_access_enabled

  dynamic "georeplications" {
    for_each = var.acr_enable_georeplication ? [1] : []
    content {
      location                = var.acr_georeplication_location
      zone_redundancy_enabled = var.acr_zone_redundancy_enabled
    }
  }
}
