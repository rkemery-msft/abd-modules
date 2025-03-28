resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}-${random_pet.name_suffix.id}-vnet"
  address_space       = var.vnet_address_space
  location            = local.rg_location 
  resource_group_name = local.rg_name     
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}-${random_pet.name_suffix.id}-subnet"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.name_prefix}-${random_pet.name_suffix.id}-pip"
  location            = local.rg_location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-${random_pet.name_suffix.id}-nsg"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr 
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*" 
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name_prefix}-${random_pet.name_suffix.id}-nic"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "${var.name_prefix}-${random_pet.name_suffix.id}-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}