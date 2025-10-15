resource_group_name = "rg-avd-prod"
vnet_name           = "vnet-avd"
subnet_name         = "subnet-sessionhosts"

domain_name         = "corp.contoso.com"
domain_user         = "corp\\joinuser"
domain_password     = "YourP@ssword123"

admin_username      = "localadmin"
admin_password      = "AdminP@ssword123"

# Define 3 host pools
avd_hostpools = {
  "AVD-HP-FIN" = {
    vm_count = 30
    vm_size  = "Standard_D8s_v5"
  }
  "AVD-HP-HR" = {
    vm_count = 20
    vm_size  = "Standard_D4s_v5"
  }
  "AVD-HP-IT" = {
    vm_count = 40
    vm_size  = "Standard_D8s_v5"
  }
}

# Windows Server image (AVD compatible)
vm_image = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition"
  version   = "latest"
}
