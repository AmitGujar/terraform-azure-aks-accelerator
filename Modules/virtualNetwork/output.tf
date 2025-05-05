output "virtual_network_name" {
  value = azurerm_virtual_network.virtual_network.name
}

output "subnet_ids" {
  value = { for s in azurerm_subnet.vnet_subnets : s.name => s.id }
}

output "virtual_network_id" {
  value = azurerm_virtual_network.virtual_network.id
}

output "last_subnet_index" {
  value = length(var.address_prefixes_to_subnet_names) - 1
}