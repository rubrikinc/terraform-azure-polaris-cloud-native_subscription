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

variable "exocompute_details" {
  description = "Region, VNet, Subnet and pod CIDR for Exocompute."
  type = map(
    object(
      {
        region                   = string
        pod_overlay_network_cidr = string
        subnet_name              = string
        vnet_name                = string
        vnet_resource_group_name = string
      }
    )
  )
  default = {}
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

module "polaris_azure_cloud_native_tenant" {
  source = "rubrikinc/polaris-cloud-native_tenant/azure"
}

module "polaris_azure_cloud_native_subscription" {
  source = "../.."

  azure_service_principal_object_id   = module.polaris_azure_cloud_native_tenant.azure_service_principal_object_id
  rsc_service_principal_tenant_domain = module.polaris_azure_cloud_native_tenant.rsc_service_principal_tenant_domain
  exocompute_details                  = var.exocompute_details

  azure_resource_group_name   = "Basic-Example"
  azure_resource_group_region = "westus"
  azure_resource_group_tags = {
    "Environment" = "Test"
    "Owner"       = "Terraform"
  }

  regions_to_protect = [
    "westus",
  ]

  rsc_azure_features = [
    "AZURE_SQL_DB_PROTECTION",
    "AZURE_SQL_MI_PROTECTION",
    "CLOUD_NATIVE_ARCHIVAL",
    "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION",
    "CLOUD_NATIVE_PROTECTION",
    "EXOCOMPUTE",
  ]
}
