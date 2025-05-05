output "private_dns_zone_ids" {
  value = { for k, v in azurerm_private_dns_zone.private_dns_zone : k => v.id }
}