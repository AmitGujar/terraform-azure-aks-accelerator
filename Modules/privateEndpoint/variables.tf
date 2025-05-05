variable "private_dns_zone" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "private_dns_zone_link" {
  type = map(string)
}

variable "virtual_network_id" {
  type = string
}

variable "private_endpoint_dns_records" {
  type = map(object({
    name                = string
    zone_name           = string
    resource_group_name = string
    ttl                 = number
    records             = list(string)
  }))
}

variable "private_endpoint_name" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "endpoint_subnet_id" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "acr_id" {
  type = string

}

variable "keyvault_name" {
  type = string
}

variable "keyvault_id" {
  type = string
}
