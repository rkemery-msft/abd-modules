resource "random_pet" "name_suffix" {
  prefix = var.name_prefix
  length = 1 
}

locals {
  create_rg = var.resource_group_name == null
}

data "azurerm_resource_group" "existing" {
  count = local.create_rg ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "new" {
  count    = local.create_rg ? 1 : 0
  location = var.location 
  name     = "${var.name_prefix}-${random_pet.name_suffix.id}-rg"
  tags     = var.tags
}

locals {
  rg_name     = local.create_rg ? azurerm_resource_group.new[0].name : data.azurerm_resource_group.existing[0].name
  rg_location = local.create_rg ? azurerm_resource_group.new[0].location : data.azurerm_resource_group.existing[0].location
}

resource "random_pet" "ssh_key_name" {
  prefix = "${var.name_prefix}-sshkey"
  length = 1
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  location  = local.rg_location
  parent_id = local.create_rg ? azurerm_resource_group.new[0].id : data.azurerm_resource_group.existing[0].id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "local_file" "ssh_private_key_file" {
  content         = azapi_resource_action.ssh_public_key_gen.output.privateKey
  filename        = "${path.cwd}/id_rsa_${var.name_prefix}_${random_pet.name_suffix.id}"
  file_permission = "0600"

  depends_on = [azapi_resource_action.ssh_public_key_gen]
}

resource "local_file" "ssh_public_key_file" {
  content         = azapi_resource_action.ssh_public_key_gen.output.publicKey
  filename        = "${local_file.ssh_private_key_file.filename}.pub"
  file_permission = "0644"

  depends_on = [azapi_resource_action.ssh_public_key_gen]
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.name_prefix}-${random_pet.name_suffix.id}-vm"
  location                        = local.rg_location
  resource_group_name             = local.rg_name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = var.vm_size
  disable_password_authentication = true
  admin_username                  = var.admin_username
  tags                            = var.tags

  os_disk {
    name                 = "${var.name_prefix}-${random_pet.name_suffix.id}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_type
  }

  source_image_reference {
    publisher = var.vm_image_details["publisher"]
    offer     = var.vm_image_details["offer"]
    sku       = var.vm_image_details["sku"]
    version   = var.vm_image_details["version"]
  }

  computer_name = substr("${var.name_prefix}-${random_pet.name_suffix.id}-vm", 0, 63)

  admin_ssh_key {
    username   = var.admin_username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }
}