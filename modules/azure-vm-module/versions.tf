terraform {
  required_version = ">= 1.11.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.1"
    }
    azapi = { 
      source  = "azure/azapi"
      version = ">= 2.3.0" 
    }
    local = { 
      source = "hashicorp/local"
      version = ">= 2.5.2"
    }
  }
}