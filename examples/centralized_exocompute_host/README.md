# Azure Subscription as a Centralized Exocompute Host
The configuration in this directory adds an Azure tenant and Azure subscription to RSC. The subscription is configured
to be used as a Centralized Exocompute host in 2 regions.

## Usage
To run this example you need to execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these
resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >=2.15.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.10.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.10.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_polaris_azure_cloud_native_subscription"></a> [polaris\_azure\_cloud\_native\_subscription](#module\_polaris\_azure\_cloud\_native\_subscription) | ../.. | n/a |
| <a name="module_polaris_azure_cloud_native_tenant"></a> [polaris\_azure\_cloud\_native\_tenant](#module\_polaris\_azure\_cloud\_native\_tenant) | ../../../terraform-azure-polaris-cloud-native_tenant | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.eastus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.westus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.eastus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.westus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [time_sleep.wait_for_tenant](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID. | `string` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Azure tenant ID. | `string` | n/a | yes |
| <a name="input_polaris_credentials"></a> [polaris\_credentials](#input\_polaris\_credentials) | RSC service account credentials or the path to a file containing the service account credentials. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_service_principal_object_id"></a> [azure\_service\_principal\_object\_id](#output\_azure\_service\_principal\_object\_id) | The Azure object id of the service principal used by RSC. |
| <a name="output_polaris_azure_subscription_id"></a> [polaris\_azure\_subscription\_id](#output\_polaris\_azure\_subscription\_id) | The RSC cloud account ID of the Centralized Exocompute Azure subscription. |
| <a name="output_rsc_service_principal_tenant_domain"></a> [rsc\_service\_principal\_tenant\_domain](#output\_rsc\_service\_principal\_tenant\_domain) | The Azure domain name of the service principal used by RSC. |
<!-- END_TF_DOCS -->
