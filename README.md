# Terraform Module - Azure Rubrik Cloud Native Subscription
This module adds an Azure subscription to Rubrik Security Cloud (RSC/Polaris) using an existing tenant.

## Usage
```hcl
module "polaris_azure_cloud_native_subscription" {
  source = "rubrikinc/polaris-cloud-native_subscription/azure"

  azure_service_principal_object_id   = "6473bd4c-6341-4bf6-85dd-059976075869"
  rsc_service_principal_tenant_domain = "my-tenant-domain.onmicrosoft.com"

  azure_resource_group_name   = "RubrikBackups-RG-DontDelete-Terraform"
  azure_resource_group_region = "westus"
  azure_resource_group_tags   = {
    "Environment" = "Test"
    "Owner"       = "Terraform" 
  }

  regions_to_protect = [
    "westus",
  ]

  rsc_features = {
    AZURE_SQL_MI_PROTECTION = {
      permission_groups = ["BASIC", "RECOVERY", "BACKUP_V2"]
    }
    AZURE_SQL_DB_PROTECTION = {
      permission_groups = ["BASIC", "RECOVERY", "BACKUP_V2"]
    }
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = ["BASIC", "ENCRYPTION"]
    }
    CLOUD_NATIVE_ARCHIVAL_ENCRYPTION = {
      permission_groups = ["BASIC", "ENCRYPTION"]
    }
    CLOUD_NATIVE_BLOB_PROTECTION = {
      permission_groups = ["BASIC", "RECOVERY"]
    }
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = ["BASIC", "EXPORT_AND_RESTORE", "FILE_LEVEL_RECOVERY"]
    }
    EXOCOMPUTE = {
      permission_groups = ["BASIC"]
    }
  }

  exocompute_details  = {
    exocompute_config = {
      region                    = "westus"
      subnet_name               = "subnet1"
      vnet_name                 = "vnet1"
      vnet_resource_group_name  = "vnet-rg"

      # Optional advanced Exocompute configuration.
      optional_config = {
        allowlist_additional_ips = ["1.2.3.4"]
        allowlist_rubrik_ips    = true
        cluster_access          = "AKS_CLUSTER_ACCESS_TYPE_PRIVATE"
        cluster_tier            = "AKS_CLUSTER_TIER_FREE"
        disk_encryption_at_host = true
        max_node_count          = "AKS_NODE_COUNT_BUCKET_SMALL"
      }
    }
  }
}
```

## Examples
- [Basic Subscription](examples/basic)
- [Centralized Exocompute App](examples/centralized_exocompute)
- [Centralized Exocompute Host](examples/centralized_exocompute_host)

## Optional Exocompute Configuration

The `optional_config` block inside `exocompute_details` exposes advanced settings for the Exocompute AKS cluster.
All fields are optional — when omitted the provider defaults are used.

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `allowlist_additional_ips` | `set(string)` | Additional IP addresses to allowlist for the AKS API server. Requires `allowlist_rubrik_ips = true`. | `null` |
| `allowlist_rubrik_ips` | `bool` | Allowlist Rubrik IPs for the AKS API server. | `false` |
| `cluster_access` | `string` | AKS cluster access type. Values: `AKS_CLUSTER_ACCESS_TYPE_PUBLIC`, `AKS_CLUSTER_ACCESS_TYPE_PRIVATE`. | `AKS_CLUSTER_ACCESS_TYPE_PRIVATE` |
| `cluster_tier` | `string` | AKS cluster tier. Values: `AKS_CLUSTER_TIER_FREE`, `AKS_CLUSTER_TIER_STANDARD`. | `AKS_CLUSTER_TIER_FREE` |
| `disk_encryption_at_host` | `bool` | Enable disk encryption at host. | `false` |
| `max_node_count` | `string` | Max nodes per cluster. Values: `AKS_NODE_COUNT_BUCKET_SMALL` (32), `AKS_NODE_COUNT_BUCKET_MEDIUM` (64), `AKS_NODE_COUNT_BUCKET_LARGE` (128), `AKS_NODE_COUNT_BUCKET_XLARGE` (256). | `AKS_NODE_COUNT_BUCKET_MEDIUM` |
| `private_exocompute_dns_zone_id` | `string` | Azure resource ID of the private DNS zone for resolving the API server URL of a private cluster. | `null` |
| `resource_group_prefix` | `string` | Prefix for resource groups associated with the cluster nodes. | `null` |
| `snapshot_private_access_dns_zone_id` | `string` | Azure resource ID of the private DNS zone for resolving private endpoints linked to snapshots. | `null` |
| `user_defined_routing` | `bool` | Enable user-defined routing for Exocompute egress traffic. | `false` |

> **Note:** All `optional_config` fields force a new Exocompute resource to be created when changed.

## Changelog

### v2.3.0
* Add `optional_config` block to the `exocompute_details` variable, enabling configuration of advanced Exocompute
  settings such as IP allowlisting, cluster access, cluster tier, disk encryption at host, node count limits, private
  DNS zones, resource group prefix, and user-defined routing.

### v2.2.0
* Update the version constraint of the `rubrikinc/polaris` provider to `>=1.1.6`.
* Add `rsc_features` input variable, used to specify RSC features to enable with permission groups. Exactly one of
 `rsc_features` and `rsc_azure_features` should be specified. If both are specified, `rsc_feature` take precedence.
* Add support for the `CLOUD_NATIVE_BLOB_PROTECTION` RSC feature. Note, this feature requires permission groups to be
  specified.

### v2.1.1
* Remove unnecessary `time_sleep` resources from examples.

### v2.1.0
* Mark `azure_subscription_id` and `polaris_credentials` input variables as deprecated. They are no longer used by the
  module and have no replacements.
* Move example configuration code from the README.md file to the examples directory.

## Troubleshooting

### Error: Missing Tenant
When you remove the last subscription from an RSC tenant, the tenant will be automatically removed from RSC. To add
another subscription to the tenant, the tenant must first be added back.

The following error, when applying a Terraform configuration, indicates that the tenant is missing:
```
╷
│ Error: failed to add subscription: failed to request addAzureCloudAccountWithoutOauth: graphql response body is an error (status code 200): NOT_FOUND: Failed to get service principal in the tenant. Azure may take some time to sync service principal. Please try after a minute (Azure error: [Unknown] Unknown service error) (code: 404, traceId: T908tqj5/shh8TMK9rX2lA==)
│
│   with polaris_azure_subscription.polaris,
│   on main.tf line 84, in resource "polaris_azure_subscription" "polaris":
│   84: resource "polaris_azure_subscription" "polaris" {
│
```
Solution: Taint the `polaris_azure_service_principal.polaris` resource and re-run the apply operation.

## How You Can Help
We welcome contributions from the community. From updating the documentation to adding more functionality, all ideas are
welcome. Thank you in advance for all of your issues, pull requests, and comments!
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Contributing Guide](CONTRIBUTING.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.10.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.10.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_user_assigned_identity.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [polaris_azure_exocompute.polaris](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_exocompute) | resource |
| [polaris_azure_subscription.default](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_subscription) | resource |
| [azurerm_subnet.polaris](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [polaris_azure_permissions.default](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/azure_permissions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_group_name"></a> [azure\_resource\_group\_name](#input\_azure\_resource\_group\_name) | Name of the Azure resource group to store snapshots and Exocompute artifacts. | `string` | `"Rubrik-Backups-RG-Do-Not-Delete"` | no |
| <a name="input_azure_resource_group_region"></a> [azure\_resource\_group\_region](#input\_azure\_resource\_group\_region) | Region of the Azure resource group to store snapshots and Exocompute artifacts. | `string` | n/a | yes |
| <a name="input_azure_resource_group_tags"></a> [azure\_resource\_group\_tags](#input\_azure\_resource\_group\_tags) | Tags to apply to the Azure resource group to store snapshots and Exocompute artifacts. | `map(string)` | `{}` | no |
| <a name="input_azure_service_principal_object_id"></a> [azure\_service\_principal\_object\_id](#input\_azure\_service\_principal\_object\_id) | Azure service principal object id. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Deprecated: no replacement. | `string` | `null` | no |
| <a name="input_delete_snapshots_on_destroy"></a> [delete\_snapshots\_on\_destroy](#input\_delete\_snapshots\_on\_destroy) | Should snapshots be deleted when the resource is destroyed. | `bool` | `false` | no |
| <a name="input_exocompute_details"></a> [exocompute\_details](#input\_exocompute\_details) | Region, VNet, Subnet, pod CIDR and optional advanced configuration for Exocompute. | <pre>map(<br/>    object(<br/>      {<br/>        region                   = string<br/>        pod_overlay_network_cidr = string<br/>        subnet_name              = string<br/>        vnet_name                = string<br/>        vnet_resource_group_name = string<br/>        optional_config = optional(object({<br/>          # Additional IP addresses to allowlist for the AKS API server.<br/>          # Requires allowlist_rubrik_ips = true.<br/>          allowlist_additional_ips = optional(set(string))<br/><br/>          # Allowlist Rubrik IPs for the AKS API server. Default: false.<br/>          allowlist_rubrik_ips = optional(bool)<br/><br/>          # AKS cluster access type. Possible values are<br/>          # AKS_CLUSTER_ACCESS_TYPE_PUBLIC and AKS_CLUSTER_ACCESS_TYPE_PRIVATE (default).<br/>          cluster_access = optional(string)<br/><br/>          # AKS cluster tier. Possible values are<br/>          # AKS_CLUSTER_TIER_FREE (default) and AKS_CLUSTER_TIER_STANDARD.<br/>          cluster_tier = optional(string)<br/><br/>          # Enable disk encryption at host. Default: false.<br/>          disk_encryption_at_host = optional(bool)<br/><br/>          # Max nodes per cluster. Possible values are AKS_NODE_COUNT_BUCKET_SMALL (32),<br/>          # AKS_NODE_COUNT_BUCKET_MEDIUM (64, default), AKS_NODE_COUNT_BUCKET_LARGE (128) and<br/>          # AKS_NODE_COUNT_BUCKET_XLARGE (256). Ensure the subnet has enough IP addresses.<br/>          max_node_count = optional(string)<br/><br/>          # Azure resource ID of the private DNS zone for resolving the API server URL<br/>          # of a private cluster. If empty, Azure creates one automatically.<br/>          private_exocompute_dns_zone_id = optional(string)<br/><br/>          # Prefix for resource groups associated with the cluster nodes.<br/>          resource_group_prefix = optional(string)<br/><br/>          # Azure resource ID of the private DNS zone for resolving private endpoints<br/>          # linked to snapshots. If empty, a new zone is created in the Exocompute<br/>          # resource group.<br/>          snapshot_private_access_dns_zone_id = optional(string)<br/><br/>          # Enable user-defined routing for Exocompute egress traffic. Default: false.<br/>          user_defined_routing = optional(bool)<br/>        }))<br/>      }<br/>    )<br/>  )</pre> | `{}` | no |
| <a name="input_polaris_credentials"></a> [polaris\_credentials](#input\_polaris\_credentials) | Deprecated: no replacement. | `string` | `null` | no |
| <a name="input_regions_to_protect"></a> [regions\_to\_protect](#input\_regions\_to\_protect) | List of Azure regions to protect. | `list(string)` | n/a | yes |
| <a name="input_rsc_azure_features"></a> [rsc\_azure\_features](#input\_rsc\_azure\_features) | List of RSC features to enable. To specify permission groups for the features use rsc\_features variable instead. | `list(string)` | `null` | no |
| <a name="input_rsc_features"></a> [rsc\_features](#input\_rsc\_features) | RSC features to enable with permission groups. | <pre>map(object({<br/>    permission_groups = set(string)<br/>  }))</pre> | `null` | no |
| <a name="input_rsc_service_principal_tenant_domain"></a> [rsc\_service\_principal\_tenant\_domain](#input\_rsc\_service\_principal\_tenant\_domain) | Tenant domain of the Service Principal created in RSC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_polaris_azure_subscription_id"></a> [polaris\_azure\_subscription\_id](#output\_polaris\_azure\_subscription\_id) | The RSC cloud account ID of the Azure subscription. |
<!-- END_TF_DOCS -->
