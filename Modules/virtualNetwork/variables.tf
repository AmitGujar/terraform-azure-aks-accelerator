variable "address_prefixes_to_subnet_names" {
  type = list(string)
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "location" {
  type = string

}

variable "vnet_cidr" {
  type = list(string)
}

variable "subnet_prefix_length" {
  description = "The prefix length for the subnets."
  type        = number
}
