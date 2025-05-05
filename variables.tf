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
  description = "List of RSC Azure features to enable."
}

variable "rsc_service_principal_tenant_domain" {
  type        = string
  description = "Tenant domain of the Service Principal created in RSC."
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
