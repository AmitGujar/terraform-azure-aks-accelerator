variable "acr_enable_georeplication" {
  type = bool
}

variable "acr_georeplication_location" {
  type = string
}

variable "acr_zone_redundancy_enabled" {
  type = bool
}

variable "acr_name" {
  type = string
}

variable "acr_sku" {
  type = string
  validation {
    condition     = var.acr_sku == "Standard" || var.acr_sku == "Premium"
    error_message = "Invalid SKU. Valid values are Standard, and Premium."
  }
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "acr_admin_enabled_choice" {
  type    = bool
}

variable "acr_public_network_access_enabled" {
  type = bool
}

variable "public_access" {
  type = bool
}
