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
  description = "Region, VNet, Subnet, pod CIDR and optional advanced configuration for Exocompute."
  type = map(
    object(
      {
        region                   = string
        pod_overlay_network_cidr = string
        subnet_name              = string
        vnet_name                = string
        vnet_resource_group_name = string
        optional_config = optional(object({
          # Additional IP addresses to allowlist for the AKS API server.
          # Requires allowlist_rubrik_ips = true.
          allowlist_additional_ips = optional(set(string))

          # Allowlist Rubrik IPs for the AKS API server. Default: false.
          allowlist_rubrik_ips = optional(bool)

          # AKS cluster access type. Possible values are
          # AKS_CLUSTER_ACCESS_TYPE_PUBLIC and AKS_CLUSTER_ACCESS_TYPE_PRIVATE (default).
          cluster_access = optional(string)

          # AKS cluster tier. Possible values are
          # AKS_CLUSTER_TIER_FREE (default) and AKS_CLUSTER_TIER_STANDARD.
          cluster_tier = optional(string)

          # Enable disk encryption at host. Default: false.
          disk_encryption_at_host = optional(bool)

          # Max nodes per cluster. Possible values are AKS_NODE_COUNT_BUCKET_SMALL (32),
          # AKS_NODE_COUNT_BUCKET_MEDIUM (64, default), AKS_NODE_COUNT_BUCKET_LARGE (128) and
          # AKS_NODE_COUNT_BUCKET_XLARGE (256). Ensure the subnet has enough IP addresses.
          max_node_count = optional(string)

          # Azure resource ID of the private DNS zone for resolving the API server URL
          # of a private cluster. If empty, Azure creates one automatically.
          private_exocompute_dns_zone_id = optional(string)

          # Prefix for resource groups associated with the cluster nodes.
          resource_group_prefix = optional(string)

          # Azure resource ID of the private DNS zone for resolving private endpoints
          # linked to snapshots. If empty, a new zone is created in the Exocompute
          # resource group.
          snapshot_private_access_dns_zone_id = optional(string)

          # Enable user-defined routing for Exocompute egress traffic. Default: false.
          user_defined_routing = optional(bool)
        }))
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

variable "sql_db_protection_managed_identity_name" {
  type        = string
  description = "Managed Identity Name used for SQL DB Protection"
  default     = null
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
