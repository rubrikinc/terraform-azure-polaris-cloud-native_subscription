terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    polaris = {
      source = "rubrikinc/polaris"
      version = ">=0.9.0-beta.8"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}
