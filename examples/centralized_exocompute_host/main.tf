terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.15.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.10.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.0"
    }
  }
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID."
}

variable "polaris_credentials" {
  type        = string
  description = "RSC service account credentials or the path to a file containing the service account credentials."
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
}

provider "polaris" {
  credentials = var.polaris_credentials
}

# Example resource group and virtual network for Exocompute in the East US
# region.
resource "azurerm_resource_group" "eastus" {
  name     = "terraform-test-vnet1-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "eastus" {
  name                = "terraform-test-vnet1"
  location            = azurerm_resource_group.eastus.location
  resource_group_name = azurerm_resource_group.eastus.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }
}

# Example resource group and virtual network for Exocompute in the West US
# region.
resource "azurerm_resource_group" "westus" {
  name     = "terraform-test-vnet2-rg"
  location = "westus"
}

resource "azurerm_virtual_network" "westus" {
  name                = "terraform-test-vnet2"
  location            = azurerm_resource_group.westus.location
  resource_group_name = azurerm_resource_group.westus.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }
}

module "polaris_azure_cloud_native_tenant" {
  source = "rubrikinc/polaris-cloud-native_tenant/azure"
}

module "polaris_azure_cloud_native_subscription" {
  source = "../.."

  azure_service_principal_object_id   = module.polaris_azure_cloud_native_tenant.azure_service_principal_object_id
  rsc_service_principal_tenant_domain = module.polaris_azure_cloud_native_tenant.rsc_service_principal_tenant_domain

  azure_resource_group_name   = "Centralized-Exocompute-Host-Example"
  azure_resource_group_region = "westus"
  azure_resource_group_tags = {
    "Environment" = "Test"
    "Owner"       = "Terraform"
  }

  regions_to_protect = [
    "eastus",
    "westus",
  ]

  rsc_azure_features = [
    "EXOCOMPUTE",
  ]

  exocompute_details = {
    exocompute_config_1 = {
      region                   = "eastus"
      subnet_name              = "subnet1"
      vnet_name                = azurerm_virtual_network.eastus.name
      vnet_resource_group_name = azurerm_virtual_network.eastus.resource_group_name
      pod_overlay_network_cidr = "10.1.0.0/16"
    }
    exocompute_config_2 = {
      region                   = "westus"
      subnet_name              = "subnet1"
      vnet_name                = azurerm_virtual_network.westus.name
      vnet_resource_group_name = azurerm_virtual_network.westus.resource_group_name
      pod_overlay_network_cidr = "10.1.0.0/16"
    }
  }
}

# The output values can be used with the centralized_exocompute example.
output "azure_service_principal_object_id" {
  value       = module.polaris_azure_cloud_native_tenant.azure_service_principal_object_id
  description = "The Azure object id of the service principal used by RSC."
}

output "polaris_azure_subscription_id" {
  value       = module.polaris_azure_cloud_native_subscription.polaris_azure_subscription_id
  description = "The RSC cloud account ID of the Centralized Exocompute Azure subscription."
}

output "rsc_service_principal_tenant_domain" {
  value       = module.polaris_azure_cloud_native_tenant.rsc_service_principal_tenant_domain
  description = "The Azure domain name of the service principal used by RSC."
}
