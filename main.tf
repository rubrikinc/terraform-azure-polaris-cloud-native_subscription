locals {
  exocompute_regions = flatten([
    for exocompute_detail, details in var.exocompute_details : details.region
  ])
}

# The subscription the Azure RM is running with.
data "azurerm_subscription" "current" {}

# Azure permissions required for Cloud Native Protection.
data "polaris_azure_permissions" "default" {
  for_each = toset(var.rsc_azure_features)

  feature = each.key
}

# Add Azure Resource Group to for snapshots and Exocompute artifacts.
resource "azurerm_resource_group" "default" {
  name     = var.azure_resource_group_name
  location = var.azure_resource_group_region
  tags     = var.azure_resource_group_tags
}

# Create a role scoped to the subscription in Azure for each feature with the required
# permissions.
resource "azurerm_role_definition" "subscription" {
  for_each = toset(var.rsc_azure_features)

  name        = "Rubrik Security Cloud SubRole ${each.key} - terraform - ${data.azurerm_subscription.current.subscription_id}"
  description = "Rubrik Security Cloud Subscription role for ${each.key} - Terraform Generated"
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

  name        = "Rubrik Security Cloud RGRole ${each.key} - terraform - ${data.azurerm_subscription.current.subscription_id}"
  description = "Rubrik Security Cloud Resource Group role for ${each.key} - Terraform Generated"
  scope       = azurerm_resource_group.default.id

  dynamic "permissions" {
    for_each = length(
      concat(
        data.polaris_azure_permissions.default[each.value].resource_group_actions,
        data.polaris_azure_permissions.default[each.value].resource_group_data_actions,
        data.polaris_azure_permissions.default[each.value].resource_group_not_actions,
        data.polaris_azure_permissions.default[each.value].resource_group_not_data_actions
      )
    ) > 0 ? [1] : []
    content {
      actions          = data.polaris_azure_permissions.default[each.key].resource_group_actions
      data_actions     = data.polaris_azure_permissions.default[each.key].resource_group_data_actions
      not_actions      = data.polaris_azure_permissions.default[each.key].resource_group_not_actions
      not_data_actions = data.polaris_azure_permissions.default[each.key].resource_group_not_data_actions
    }
  }
}

# Assign the Subscription level role to the service principal used by RSC. Note that the
# principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "subscription" {
  for_each = toset(var.rsc_azure_features)

  principal_id       = var.azure_service_principal_object_id
  role_definition_id = azurerm_role_definition.subscription[each.key].role_definition_resource_id
  scope              = data.azurerm_subscription.current.id
}

# Assign the Resource Group level role to the service principal used by RSC. Note that the
# principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "resource_group" {
  for_each = toset(var.rsc_azure_features)

  principal_id       = var.azure_service_principal_object_id
  role_definition_id = azurerm_role_definition.resource_group[each.key].role_definition_resource_id
  scope              = azurerm_resource_group.default.id
}

resource "azurerm_user_assigned_identity" "default" {
  count = contains(var.rsc_azure_features, "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION") ? 1 : 0

  location            = azurerm_resource_group.default.location
  name                = "RubrikManagedIdentity-terraform-${data.azurerm_subscription.current.subscription_id}"
  resource_group_name = azurerm_resource_group.default.name
}

# Add the Azure subscription to RSC enabling only the feature found in the rsc_features variable.
resource "polaris_azure_subscription" "default" {
  delete_snapshots_on_destroy = var.delete_snapshots_on_destroy
  subscription_id             = element(split("/", data.azurerm_subscription.current.id), 2)
  subscription_name           = data.azurerm_subscription.current.display_name
  tenant_domain               = var.rsc_service_principal_tenant_domain

  dynamic "cloud_native_archival" {
    for_each = contains(var.rsc_azure_features, "CLOUD_NATIVE_ARCHIVAL") ? [1] : []

    content {
      permissions           = data.polaris_azure_permissions.default["CLOUD_NATIVE_ARCHIVAL"].id
      regions               = var.regions_to_protect
      resource_group_name   = var.azure_resource_group_name
      resource_group_region = var.azure_resource_group_region
      resource_group_tags   = var.azure_resource_group_tags
    }
  }

  dynamic "cloud_native_archival_encryption" {
    for_each = contains(var.rsc_azure_features, "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION") ? [1] : []

    content {
      permissions                                        = data.polaris_azure_permissions.default["CLOUD_NATIVE_ARCHIVAL_ENCRYPTION"].id
      regions                                            = var.regions_to_protect
      resource_group_name                                = var.azure_resource_group_name
      resource_group_region                              = var.azure_resource_group_region
      resource_group_tags                                = var.azure_resource_group_tags
      user_assigned_managed_identity_name                = azurerm_user_assigned_identity.default[0].name
      user_assigned_managed_identity_principal_id        = azurerm_user_assigned_identity.default[0].principal_id
      user_assigned_managed_identity_region              = var.azure_resource_group_region
      user_assigned_managed_identity_resource_group_name = azurerm_resource_group.default.name
    }
  }

  dynamic "cloud_native_protection" {
    for_each = contains(var.rsc_azure_features, "CLOUD_NATIVE_PROTECTION") ? [1] : []

    content {
      permissions           = data.polaris_azure_permissions.default["CLOUD_NATIVE_PROTECTION"].id
      regions               = var.regions_to_protect
      resource_group_name   = var.azure_resource_group_name
      resource_group_region = var.azure_resource_group_region
      resource_group_tags   = var.azure_resource_group_tags
    }
  }

  dynamic "exocompute" {
    for_each = contains(var.rsc_azure_features, "EXOCOMPUTE") ? [1] : []

    content {
      permissions           = data.polaris_azure_permissions.default["EXOCOMPUTE"].id
      regions               = var.regions_to_protect
      resource_group_name   = var.azure_resource_group_name
      resource_group_region = var.azure_resource_group_region
      resource_group_tags   = var.azure_resource_group_tags
    }
  }

  dynamic "sql_db_protection" {
    for_each = contains(var.rsc_azure_features, "AZURE_SQL_DB_PROTECTION") ? [1] : []

    content {
      permissions = data.polaris_azure_permissions.default["AZURE_SQL_DB_PROTECTION"].id
      regions     = var.regions_to_protect
    }
  }

  dynamic "sql_mi_protection" {
    for_each = contains(var.rsc_azure_features, "AZURE_SQL_MI_PROTECTION") ? [1] : []

    content {
      permissions = data.polaris_azure_permissions.default["AZURE_SQL_MI_PROTECTION"].id
      regions     = var.regions_to_protect
    }
  }

  # Make sure the subscription is removed from RSC before the roles are removed
  # in Azure.
  depends_on = [
    azurerm_role_assignment.subscription,
    azurerm_role_definition.subscription,
    azurerm_role_assignment.resource_group,
    azurerm_role_definition.resource_group,
  ]
}

data "azurerm_subnet" "polaris" {
  for_each = { for k, v in var.exocompute_details : k => v if contains(var.rsc_azure_features, "EXOCOMPUTE") }

  name                 = each.value["subnet_name"]
  virtual_network_name = each.value["vnet_name"]
  resource_group_name  = each.value["vnet_resource_group_name"]
}

# Configure the subscription to host Exocompute.
resource "polaris_azure_exocompute" "polaris" {
  for_each = { for k, v in var.exocompute_details : k => v if contains(var.rsc_azure_features, "EXOCOMPUTE") }

  cloud_account_id         = polaris_azure_subscription.default.id
  pod_overlay_network_cidr = each.value["pod_overlay_network_cidr"]
  region                   = each.value["region"]
  subnet                   = data.azurerm_subnet.polaris[each.key].id
}
