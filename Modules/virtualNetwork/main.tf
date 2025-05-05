resource "azurerm_virtual_network" "virtual_network" {
  name                = var.vnet_name
  address_space       = var.vnet_cidr
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_subnet" "vnet_subnets" {
  for_each             = { for i, name in var.address_prefixes_to_subnet_names : name => cidrsubnet(var.vnet_cidr[0], var.subnet_prefix_length, i) }
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [each.value]
}
