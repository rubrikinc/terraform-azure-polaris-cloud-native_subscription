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

  rsc_azure_features = [
    "AZURE_SQL_DB_PROTECTION",
    "AZURE_SQL_MI_PROTECTION",
    "CLOUD_NATIVE_ARCHIVAL",
    "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION",
    "CLOUD_NATIVE_PROTECTION",
    "EXOCOMPUTE",
  ]

  exocompute_details  = {
    exocompute_config = {
      region                    = "westus"
      subnet_name               = "subnet1"
      vnet_name                 = "vnet1"
      vnet_resource_group_name  = "vnet-rg"
    }
  }
}
```

## Examples
- [Basic Subscription](examples/basic)
- [Centralized Exocompute App](examples/centralized_exocompute)
- [Centralized Exocompute Host](examples/centralized_exocompute_host)

## Changelog

### v2.1.1
  * Remove unnecessary `time_sleep` resources from examples.

### v2.1.0
  * Mark `azure_tenant_id` and `polaris_credentials` input variables as deprecated. They are no longer used by the
    module and have no replacements.
  * Move example configuration code from the README.md file to the examples directory.

## Troubleshooting:

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.10.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.0.0 |

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
| <a name="input_exocompute_details"></a> [exocompute\_details](#input\_exocompute\_details) | Region, VNet, Subnet and pod CIDR for Exocompute. | <pre>map(<br/>    object(<br/>      {<br/>        region                   = string<br/>        pod_overlay_network_cidr = string<br/>        subnet_name              = string<br/>        vnet_name                = string<br/>        vnet_resource_group_name = string<br/>      }<br/>    )<br/>  )</pre> | `{}` | no |
| <a name="input_polaris_credentials"></a> [polaris\_credentials](#input\_polaris\_credentials) | Deprecated: no replacement. | `string` | `null` | no |
| <a name="input_regions_to_protect"></a> [regions\_to\_protect](#input\_regions\_to\_protect) | List of Azure regions to protect. | `list(string)` | n/a | yes |
| <a name="input_rsc_azure_features"></a> [rsc\_azure\_features](#input\_rsc\_azure\_features) | List of RSC Azure features to enable. | `list(string)` | n/a | yes |
| <a name="input_rsc_service_principal_tenant_domain"></a> [rsc\_service\_principal\_tenant\_domain](#input\_rsc\_service\_principal\_tenant\_domain) | Tenant domain of the Service Principal created in RSC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_polaris_azure_subscription_id"></a> [polaris\_azure\_subscription\_id](#output\_polaris\_azure\_subscription\_id) | The RSC cloud account ID of the Azure subscription. |
<!-- END_TF_DOCS -->
