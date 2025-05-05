variable "identity_type" {
  type    = string
  default = "1"
}

variable "aks_useridentity_name" {
  type    = string
  default = "aks-user-identity"

}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string

}

variable "aks_principal_id" {
  type = string

}

variable "identity_scope" {
  type = string
}
