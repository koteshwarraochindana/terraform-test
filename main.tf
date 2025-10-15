data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

# Create Host Pools
resource "azurerm_virtual_desktop_host_pool" "avd_hp" {
  for_each            = var.avd_hostpools
  name                = each.key
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  type                = "Pooled"
  load_balancer_type  = "DepthFirst"
  maximum_sessions_allowed = 20

  registration_info {
    expiration_date = "2025-12-31T23:59:59Z"
  }
}

# Create VM Scale Sets (one per hostpool)
resource "azurerm_windows_virtual_machine_scale_set" "avd_vmss" {
  for_each            = var.avd_hostpools
  name                = "${each.key}-VMSS"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = each.value.vm_size
  instances           = each.value.vm_count
  upgrade_mode        = "Manual"
  computer_name_prefix = lower(each.key)
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  source_image_reference {
    publisher = var.vm_image.publisher
    offer     = var.vm_image.offer
    sku       = var.vm_image.sku
    version   = var.vm_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  network_interface {
    name    = "${each.key}-nic"
    primary = true
    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = data.azurerm_subnet.subnet.id
    }
  }

  extension {
    name                       = "joindomain"
    publisher                  = "Microsoft.Compute"
    type                       = "JsonADDomainExtension"
    type_handler_version        = "1.3"
    auto_upgrade_minor_version  = true
    settings = jsonencode({
      "Name"    = var.domain_name
      "User"    = var.domain_user
      "Restart" = "true"
      "Options" = "3"
    })
    protected_settings = jsonencode({
      "Password" = var.domain_password
    })
  }

  depends_on = [azurerm_virtual_desktop_host_pool.avd_hp]
}

# Register Application Groups (Optional)
resource "azurerm_virtual_desktop_application_group" "avd_ag" {
  for_each            = var.avd_hostpools
  name                = "${each.key}-DAG"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.avd_hp[each.key].id
}

# Register Workspace
resource "azurerm_virtual_desktop_workspace" "avd_ws" {
  name                = "AVD-Workspace-Prod"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
}

# Link Workspace and App Groups
resource "azurerm_virtual_desktop_workspace_application_group_association" "avd_link" {
  for_each               = var.avd_hostpools
  workspace_id           = azurerm_virtual_desktop_workspace.avd_ws.id
  application_group_id   = azurerm_virtual_desktop_application_group.avd_ag[each.key].id
}
