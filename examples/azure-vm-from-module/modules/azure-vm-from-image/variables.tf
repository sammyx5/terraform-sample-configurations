variable "prefix" {
  default = "image-test"
}

variable "location" {
  description = "Resource group location"
  default     = "northeurope"
}

variable "vnet_address_space" {
  description = "Virtual networkk address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_space" {
  description = "Virtual networkk address space"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "db_vm_size" {
  description = "Database server size"
  default     = "Standard_D12_v2"
}

variable "custom_windows_img_ref_id" {
    description = "Source vm os disk snapshot id"
}

variable "admin_username" {
  description = "Database server admin username"
  default     = "ifsadmin"
}

variable "admin_password" {
  description = "Database server admin username"
  default     = "Password!1234"
}

