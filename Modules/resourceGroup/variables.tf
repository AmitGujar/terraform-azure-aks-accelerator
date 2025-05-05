variable "resource_group_name" {
  type        = string
  description = "name for the resource group"
}

variable "location" {
  type        = string
  description = "location for the resource group"
}

variable "resource_group_tags" {
  type        = map(string)
  description = "tags for the resource group"
}
