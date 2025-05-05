variable "vm_public_ip_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_ip_allocation_method" {
  type = string
}

variable "vm_security_rules" {
  description = "List of security rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

variable "vm_nsg_name" {
  type = string
}

variable "vm_nic_name" {
  type = string
}

variable "vm_subnet_id" {
  type = string
}

variable "vm_nic_configuration_name" {
  type = string
}

variable "vm_username" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "vm_os_disk_name" {
  type = string
}

variable "vm_osdisk_storage_account_type" {
  type = string
}

variable "vm_image_sku_name" {
  type = string
}

variable "vm_image_offer_name" {
  type = string
}

variable "vm_image_publisher_name" {
  type = string
}

variable "vm_image_version_name" {
  type = string
}

variable "vm_nic_private_ip_allocation_method" {
  type = string
}

variable "public_ssh_key" {
  type = string
}
