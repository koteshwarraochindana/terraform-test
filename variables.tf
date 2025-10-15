variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "vnet_name" {
  description = "Existing VNet name"
  type        = string
}

variable "subnet_name" {
  description = "Existing Subnet name"
  type        = string
}

variable "domain_name" {
  description = "Active Directory domain name"
  type        = string
}

variable "domain_user" {
  description = "Domain join username (format: domain\\user)"
  type        = string
}

variable "domain_password" {
  description = "Domain join password"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "Local admin username for VMs"
  type        = string
}

variable "admin_password" {
  description = "Local admin password for VMs"
  type        = string
  sensitive   = true
}

variable "avd_hostpools" {
  description = "Host pool configuration with desired VM count"
  type = map(object({
    vm_count = number
    vm_size  = string
  }))
}

variable "vm_image" {
  description = "VM Image reference for session hosts"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
