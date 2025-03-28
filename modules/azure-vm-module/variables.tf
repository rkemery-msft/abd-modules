variable "name_prefix" {
  description = "A prefix used for naming resources, combined with a random element for uniqueness."
  type        = string
  default     = "abd"
}

variable "location" {
  description = "The Azure region where all resources will be deployed if a new Resource Group is created."
  type        = string
}

variable "resource_group_name" {
  description = "(Optional) The name of an existing Resource Group to deploy resources into. If set to null, a new RG will be created."
  type        = string
  default     = null
}

variable "vnet_address_space" {
  description = "The address space(s) for the Virtual Network. Must be CIDR notation."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "The address prefix(es) for the default Subnet. Must be CIDR notation."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "The source CIDR block allowed to SSH into the VM. IMPORTANT: Set this to your specific public IP range (e.g., 'YOUR_IP/32') for security."
  type        = string
}

variable "vm_size" {
  description = "The size (SKU) for the Azure Linux Virtual Machine."
  type        = string
  default     = "Standard_B1ms"
}

variable "vm_image_details" {
  description = "A map containing the details (publisher, offer, sku, version) for the VM image."
  type        = map(string)
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_10-daily"
    sku       = "minimal"
    version   = "latest"
  }
  validation {
    condition     = contains(keys(var.vm_image_details), "publisher") && contains(keys(var.vm_image_details), "offer") && contains(keys(var.vm_image_details), "sku") && contains(keys(var.vm_image_details), "version")
    error_message = "The vm_image_details map must include keys: publisher, offer, sku, and version."
  }
}

variable "admin_username" {
  description = "The administrator username for the Linux VM."
  type        = string
  default     = "azureadmin"
}

variable "os_disk_storage_type" {
  description = "The storage type for the VM's OS disk (e.g., Standard_LRS, Premium_LRS)."
  type        = string
  default     = "Standard_LRS"
}

variable "tags" {
  description = "A map of tags to apply to created resources that support tags."
  type        = map(string)
  default     = {}
}