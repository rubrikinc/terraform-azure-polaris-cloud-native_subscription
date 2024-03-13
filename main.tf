locals {
  exocompute_regions = flatten([
    for exocompute_detail, details in var.exocompute_details: details.region
  ])

  rsc_instance_fqdn = (element(split("/",jsondecode(file("${var.polaris_credentials}")).access_token_uri),2))
}

# The subscription the Azure RM is running with.
data "azurerm_subscription" "current" {
}

# Azure permissions required for Cloud Native Protection.
data "polaris_azure_permissions" "cloud_native_protection" {
  count = var.enable_cloud_native_protection == true ? 1 : 0
  features = [
    "cloud-native-protection"
  ]
}

# Create a role in Azure called terraform which has the required permissions.
resource "azurerm_role_definition" "cloud_native_protection" {
  count       = var.enable_cloud_native_protection == true ? 1 : 0
  name        = "Rubrik Polaris CLOUD_NATIVE_PROTECTION - ${local.rsc_instance_fqdn}"
  description = "Rubrik Polaris role for CLOUD_NATIVE_PROTECTION - Terraform Generated"
  scope       = data.azurerm_subscription.current.id

  permissions {
    actions          = data.polaris_azure_permissions.cloud_native_protection.0.actions
    data_actions     = data.polaris_azure_permissions.cloud_native_protection.0.data_actions
    not_actions      = data.polaris_azure_permissions.cloud_native_protection.0.not_actions
    not_data_actions = data.polaris_azure_permissions.cloud_native_protection.0.not_data_actions
  }
}

# Assign the role to the service principal used by RSC. Note that the
# principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "cloud_native_protection" {
  count              = var.enable_cloud_native_protection == true ? 1 : 0
  principal_id       = var.azure_service_principal_object_id
  role_definition_id = azurerm_role_definition.cloud_native_protection.0.role_definition_resource_id
  scope              = data.azurerm_subscription.current.id
}

# Azure permissions required for Exocompute.
data "polaris_azure_permissions" "exocompute" {
  count = var.enable_exocompute == true ? 1 : 0
  features = [
    "exocompute"
  ]
}

# Create a role in Azure called terraform which has the required permissions.
resource "azurerm_role_definition" "exocompute" {
  count       = var.enable_exocompute == true ? 1 : 0
  name        = "Rubrik Polaris EXOCOMPUTE - ${local.rsc_instance_fqdn}"
  description = "Rubrik Polaris role for EXOCOMPUTE - Terraform Generated"
  scope       = data.azurerm_subscription.current.id

  permissions {
    actions          = data.polaris_azure_permissions.exocompute.0.actions
    data_actions     = data.polaris_azure_permissions.exocompute.0.data_actions
    not_actions      = data.polaris_azure_permissions.exocompute.0.not_actions
    not_data_actions = data.polaris_azure_permissions.exocompute.0.not_data_actions
  }
}

# Assign the role to the service principal used by RSC. Note that the
# principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "exocompute" {
  count              = var.enable_exocompute == true ? 1 : 0
  principal_id       = var.azure_service_principal_object_id
  role_definition_id = azurerm_role_definition.exocompute.0.role_definition_resource_id
  scope              = data.azurerm_subscription.current.id
}

# Add the Azure subscription to RSC.
resource "polaris_azure_subscription" "polaris" {
  subscription_id   = element(split("/", data.azurerm_subscription.current.id), 2)
  subscription_name = data.azurerm_subscription.current.display_name
  tenant_domain     = var.rsc_service_principal_tenant_domain

  cloud_native_protection {
    regions = var.regions_to_protect
  }

  exocompute {
    regions = local.exocompute_regions
  }

  delete_snapshots_on_destroy = var.delete_snapshots_on_destroy == true ? true : false
} 

data "azurerm_subnet" "polaris" {
  for_each             = { for k, v in var.exocompute_details : k => v if var.enable_exocompute }
  name                 = each.value["subnet_name"]
  virtual_network_name = each.value["vnet_name"]
  resource_group_name  = each.value["vnet_resource_group_name"]
}

# Configure the subscription to host Exocompute
resource "polaris_azure_exocompute" "polaris" {
  for_each        = { for k, v in var.exocompute_details : k => v if var.enable_exocompute }
  subscription_id = polaris_azure_subscription.polaris.id
  region          = each.value["region"]
  subnet          = data.azurerm_subnet.polaris[each.key].id
}