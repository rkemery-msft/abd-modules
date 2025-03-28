provider "azurerm" {
  features {}
  subscription_id = ""
}

module "abd_simple_vm" {
  source = "../modules/azure-vm-module"

  # --- Required Inputs ---
  location          = ""
  allowed_ssh_cidr  = ""

  # --- Optional Inputs (Examples) ---
  # resource_group_name = "abd-rg" # Uncomment to use an existing RG
  # name_prefix         = "test"
  # vm_size             = "Standard_B2s"
  # admin_username      = "testadmin"
  tags = {
    environment = "abd-testing"
    created_by  = "abd-terraform-module-example"
  }
}

output "vm_public_ip" {
  description = "Public IP address of the deployed VM."
  value       = module.abd_simple_vm.vm_public_ip_address
}