variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription id."
}

variable "azure_service_principal_object_id" {
  type        = string
  description = "Azure service principal object id."
}

variable "regions_to_protect" {
  type        = list
  description = "List of regions to protect."
}

variable "delete_snapshots_on_destroy" {
  type = bool
  description = "Should snapshots be deleted when the resource is destroyed."
  default = false
}

variable "enable_cloud_native_protection" {
  type        = bool
  description = "Enable cloud native protection for Azure VMs."
}

variable "enable_exocompute" {
  type        = bool
  description = "Enable Exocompute for the subscription."
}

variable "exocompute_details" {
  description = "Region and subnet pair to run Exocompute in."
  type        = map(object({
    region                    = string
#    subnet_id = string
    subnet_name               = string
    vnet_name                 = string
    vnet_resource_group_name  = string
  }))
}

variable "polaris_credentials" {
  type        = string
  description = "Full path to credentials file for RSC/Polaris."
}

variable "rsc_service_principal_tenant_domain" {
  type        = string
  description = "Tenant domain of the Service Principal created in RSC."
}