variable "keyvault_name" {
  type = string
}

variable "keyvault_sku_name" {
  type = string
  validation {
    condition     = var.keyvault_sku_name == "standard" || var.keyvault_sku_name == "premium"
    error_message = "Invalid SKU. Valid values are Standard, and Premium."
  }
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "location" {
  type = string
}

variable "keyvault_public_network_access_enabled" {
  type = bool
}

variable "keyvault_enable_rbac_authorization" {
  type = bool
}

variable "keyvault_enabled_for_deployment" {
  type = string
}

variable "object_id" {
  type = string
}

variable "keyvault_key_permissions" {
  type = list(string)
}

variable "keyvault_certificate_permissions" {
  type = list(string)
}

variable "keyvault_storage_permissions" {
  type = list(string)
}

variable "keyvault_secret_permissions" {
  type = list(string)
}
