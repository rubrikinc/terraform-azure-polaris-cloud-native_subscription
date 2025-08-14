variable "azure_resource_group_name" {
  type        = string
  description = "Name of the Azure resource group to store snapshots and Exocompute artifacts."
  default     = "Rubrik-Backups-RG-Do-Not-Delete"
}

variable "azure_resource_group_region" {
  type        = string
  description = "Region of the Azure resource group to store snapshots and Exocompute artifacts."
}

variable "azure_resource_group_tags" {
  type        = map(string)
  description = "Tags to apply to the Azure resource group to store snapshots and Exocompute artifacts."
  default     = {}
}

variable "azure_service_principal_object_id" {
  type        = string
  description = "Azure service principal object id."
}

variable "azure_subscription_id" {
  type        = string
  description = "Deprecated: no replacement."
  default     = null
}

variable "delete_snapshots_on_destroy" {
  type        = bool
  description = "Should snapshots be deleted when the resource is destroyed."
  default     = false
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
  description = "Deprecated: no replacement."
  default     = null
}

variable "regions_to_protect" {
  type        = list(string)
  description = "List of Azure regions to protect."
}

variable "rsc_azure_features" {
  type        = list(string)
  description = "List of RSC features to enable. To specify permission groups for the features use rsc_features variable instead."
  default     = null
}

variable "rsc_features" {
  type = map(object({
    permission_groups = set(string)
  }))
  description = "RSC features to enable with permission groups."
  default     = null
}

variable "rsc_service_principal_tenant_domain" {
  type        = string
  description = "Tenant domain of the Service Principal created in RSC."
}

locals {
  features = var.rsc_features != null ? var.rsc_features : { for f in var.rsc_azure_features : f => {} }
}

check "deprecations" {
  assert {
    condition     = var.azure_subscription_id == null
    error_message = "The azure_subscription_id variable has been deprecated. It has no replacement and will be removed in a future release."
  }
  assert {
    condition     = var.polaris_credentials == null
    error_message = "The polaris_credentials variable has been deprecated. It has no replacement and will be removed in a future release."
  }
}

check "features" {
  assert {
    condition     = (var.rsc_features != null && var.rsc_azure_features == null) || (var.rsc_features == null && var.rsc_azure_features != null)
    error_message = "Exactly one of rsc_features and rsc_azure_features should be set. Prefer to use rsc_features. If both are set, rsc_features takes precedence."
  }
}
