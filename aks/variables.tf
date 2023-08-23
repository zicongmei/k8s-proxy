
locals {
  name   = "zicong-aks"
  region = "eastus"

  node_count = 2
  admin_username = "azureadmin"
  k8s_version="1.25"
}


variable "username" {
  description = "proxy user name"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "proxy password"
  type        = string
  default     = ""
}