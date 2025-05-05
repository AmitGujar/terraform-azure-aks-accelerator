resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = var.private_dns_zone
  name                = each.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_link" {
  for_each              = var.private_dns_zone_link
  name                  = "${each.value}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_dns_a_record" "dns_records" {
  for_each            = var.private_endpoint_dns_records
  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.private_dns_zone[each.value.zone_name].name
  resource_group_name = each.value.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
}

resource "azurerm_private_endpoint" "terraform_acr_private_endpoint" {
  name                = "${var.acr_name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone["acr_dns_zone"].id]
  }

  private_service_connection {
    name                           = "${var.acr_name}-private-service-connection"
    private_connection_resource_id = var.acr_id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}

resource "azurerm_private_endpoint" "terraform_keyvault_private_endpoint" {
  name                = "${var.keyvault_name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone["keyvault_dns_zone"].id]
  }

  private_service_connection {
    name                           = "${var.keyvault_name}-private-service-connection"
    private_connection_resource_id = var.keyvault_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}
