locals {
  exocompute_regions = flatten([
    for exocompute_detail, details in var.exocompute_details : details.region
  ])
}

# The subscription the Azure RM is running with.
data "azurerm_subscription" "current" {
}

# Azure permissions required for Cloud Native Protection.
data "polaris_azure_permissions" "default" {
  for_each = toset(var.rsc_azure_features)
  feature = each.key
}

data "polaris_azure_permissions" "cloud_native_protection" {
  count = var.enable_cloud_native_protection == true ? 1 : 0
  features = [
    "cloud-native-protection"
  ]
}

# Create a role scoped to the subscription in Azure for each feature with the required
# permissions.
resource "azurerm_role_definition" "subscription" {
  for_each = toset(var.rsc_azure_features)
  name        = "Rubrik Polaris SubRole ${each.key} - terraform - ${data.azurerm_subscription.current.subscription_id}"
  description = "Rubrik Polaris Subscription role for ${each.key} - Terraform Generated"
  scope       = data.azurerm_subscription.current.id

  permissions {
    actions          = data.polaris_azure_permissions.default[each.key].subscription_actions
    data_actions     = data.polaris_azure_permissions.default[each.key].subscription_data_actions
    not_actions      = data.polaris_azure_permissions.default[each.key].subscription_not_actions
    not_data_actions = data.polaris_azure_permissions.default[each.key].subscription_not_data_actions
  }
}

# Create a role scoped to the resource group in the subscription in Azure for each feature with the required
# permissions.
resource "azurerm_role_definition" "resource_group" {
  for_each = toset(var.rsc_azure_features)
  name        = "Rubrik Polaris RGRole ${each.key} - terraform - ${data.azurerm_subscription.current.subscription_id}"
  description = "Rubrik Polaris Resource Group role for ${each.key} - Terraform Generated"
  scope       = azurerm_resource_group.default.id

  permissions {
    actions          = data.polaris_azure_permissions.default[each.key].resource_group_actions
    data_actions     = data.polaris_azure_permissions.default[each.key].resource_group_data_actions
    not_actions      = data.polaris_azure_permissions.default[each.key].resource_group_not_actions
    not_data_actions = data.polaris_azure_permissions.default[each.key].resource_group_not_data_actions
  }
}

# Assign the Subscription level role to the service principal used by RSC. Note that the
# principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "subscription" {
  for_each           = toset(var.rsc_azure_features)
  principal_id       = var.azure_service_principal_object_id
  role_definition_id = azurerm_role_definition.subscription[each.key].role_definition_resource_id
  scope              = data.azurerm_subscription.current.id
}

# Assign the Resource Group level role to the service principal used by RSC. Note that the
# principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "resource_group" {
  for_each           = toset(var.rsc_azure_features)
  principal_id       = var.azure_service_principal_object_id
  role_definition_id = azurerm_role_definition.resource_group[each.key].role_definition_resource_id
  scope              = azurerm_resource_group.default.id
}

# Add the Azure subscription to RSC enabling only the feature found in the rsc_features variable.

resource "polaris_azure_subscription" "default" {
  delete_snapshots_on_destroy = var.delete_snapshots_on_destroy == true ? true : false
  subscription_id             = element(split("/", data.azurerm_subscription.current.id), 2)
  subscription_name           = data.azurerm_subscription.current.display_name
  tenant_domain               = var.rsc_service_principal_tenant_domain

  dynamic "cloud_native_protection" {
    for_each = contains(var.rsc_azure_features, "CLOUD_NATIVE_PROTECTION") ? [1] : []
    content {
      permissions           = data.polaris_azure_permissions.default["CLOUD_NATIVE_PROTECTION"].id      
      regions               =  var.regions_to_protect
}

# Add the Azure subscription to RSC enabling both Cloud Native Protection and
# Exocompute. If either enable_cloud_native_protection or enable_exocompute is
# false, count will evaluate to 0.
# Note, the provider currently requires Cloud Native Protection when Exocompute
# is enabled.
resource "polaris_azure_subscription" "polaris" {
  count             = var.enable_cloud_native_protection == true ? var.enable_exocompute == true ? 1 : 0 : 0
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
  }

    dynamic "exocompute" {
    for_each = contains(var.rsc_azure_features, "EXOCOMPUTE") ? [1] : []
    content {
      permissions           = data.polaris_azure_permissions.default["EXOCOMPUTE"].id      
      regions               =  var.regions_to_protect
    }
  }

}

data "azurerm_subnet" "polaris" {
  for_each             = { for k, v in var.exocompute_details : k => v if contains(var.rsc_azure_features, "EXOCOMPUTE") }
  name                 = each.value["subnet_name"]
  virtual_network_name = each.value["vnet_name"]
  resource_group_name  = each.value["vnet_resource_group_name"]
}

#Configure the subscription to host Exocompute.
resource "polaris_azure_exocompute" "polaris" {
  for_each                  = { for k, v in var.exocompute_details : k => v if contains(var.rsc_azure_features, "EXOCOMPUTE") }
  cloud_account_id          = polaris_azure_subscription.default.id
  region          = each.value["region"]
  subnet                    = data.azurerm_subnet.polaris[each.key].id
}