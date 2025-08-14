terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.10.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.1.6"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.0"
    }
  }
}

variable "azure_service_principal_object_id" {
  type        = string
  description = "The Azure object id of the service principal used by RSC."
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "host_cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the Exocompute host subscription."
}

variable "polaris_credentials" {
  type        = string
  description = "RSC service account credentials or the path to a file containing the service account credentials."
}

variable "rsc_service_principal_tenant_domain" {
  type        = string
  description = "The Azure domain name of the service principal used by RSC."
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
}

provider "polaris" {
  credentials = var.polaris_credentials
}

module "polaris_azure_cloud_native_subscription" {
  source = "../.."

  azure_service_principal_object_id   = var.azure_service_principal_object_id
  rsc_service_principal_tenant_domain = var.rsc_service_principal_tenant_domain

  azure_resource_group_name   = "Centralized-Exocompute-Example"
  azure_resource_group_region = "westus"
  azure_resource_group_tags = {
    "Environment" = "Test"
    "Owner"       = "Terraform"
  }

  regions_to_protect = [
    "eastus",
    "westus",
  ]

  rsc_features = {
    AZURE_SQL_MI_PROTECTION = {
      permission_groups = ["BASIC", "RECOVERY", "BACKUP_V2"]
    }
    AZURE_SQL_DB_PROTECTION = {
      permission_groups = ["BASIC", "RECOVERY", "BACKUP_V2"]
    }
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = ["BASIC", "EXPORT_AND_RESTORE", "FILE_LEVEL_RECOVERY"]
    }
  }
}

resource "polaris_azure_exocompute" "app" {
  cloud_account_id      = module.polaris_azure_cloud_native_subscription.polaris_azure_subscription_id
  host_cloud_account_id = var.host_cloud_account_id
}
