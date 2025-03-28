output "vm_id" {
  description = "The Azure Resource ID of the Virtual Machine."
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_public_ip_address" {
  description = "The public IP address assigned to the Virtual Machine."
  value       = azurerm_public_ip.pip.ip_address
}

output "vm_private_ip_address" {
  description = "The private IP address assigned to the Virtual Machine."
  value       = azurerm_network_interface.nic.private_ip_address
}

output "network_interface_id" {
  description = "The ID of the Network Interface attached to the VM."
  value       = azurerm_network_interface.nic.id
}

output "resource_group_name" {
  description = "The name of the resource group containing the VM resources."
  value       = local.rg_name
}

output "resource_group_location" {
  description = "The location of the resource group containing the VM resources."
  value       = local.rg_location
}

output "subnet_id" {
  description = "The ID of the subnet where the VM is located."
  value       = azurerm_subnet.subnet.id
}

output "public_ip_id" {
  description = "The ID of the Public IP resource."
  value       = azurerm_public_ip.pip.id
}

output "nsg_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.nsg.id
}

output "ssh_private_key_filename" {
  description = "The local filename where the generated SSH private key is saved. Handle with care!"
  value       = local_file.ssh_private_key_file.filename
  sensitive   = true
}

output "ssh_public_key_filename" {
  description = "The local filename where the generated SSH public key is saved."
  value       = local_file.ssh_public_key_file.filename
}

output "ssh_public_key_content" {
  description = "The content of the generated SSH public key."
  value       = azapi_resource_action.ssh_public_key_gen.output.publicKey
}