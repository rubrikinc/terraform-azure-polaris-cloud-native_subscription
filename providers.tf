terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    polaris = {
      source = "rubrikinc/polaris"
      version = "=0.9.0-beta.3"
    }
  }
}

# Initialize the Azure RM provider from the shell environment.
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
  subscription_id = var.azure_subscription_id
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
} 