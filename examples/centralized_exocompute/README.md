# Azure Subscription using a Centralized Exocompute Host
The configuration in this directory adds an Azure subscription to RSC. The subscription is configured to use another
subscription for Exocompute. The [centralized_exocompute_host](../centralized_exocompute_host) example can be used as
the Centralized Exocompute host.

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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.10.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_polaris_azure_cloud_native_subscription"></a> [polaris\_azure\_cloud\_native\_subscription](#module\_polaris\_azure\_cloud\_native\_subscription) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [polaris_azure_exocompute.app](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_exocompute) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_service_principal_object_id"></a> [azure\_service\_principal\_object\_id](#input\_azure\_service\_principal\_object\_id) | n/a | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID. | `string` | n/a | yes |
| <a name="input_host_cloud_account_id"></a> [host\_cloud\_account\_id](#input\_host\_cloud\_account\_id) | RSC cloud account ID of the Exocompute host subscription. | `string` | n/a | yes |
| <a name="input_polaris_credentials"></a> [polaris\_credentials](#input\_polaris\_credentials) | RSC service account credentials or the path to a file containing the service account credentials. | `string` | n/a | yes |
| <a name="input_rsc_service_principal_tenant_domain"></a> [rsc\_service\_principal\_tenant\_domain](#input\_rsc\_service\_principal\_tenant\_domain) | n/a | `string` | n/a | yes |
<!-- END_TF_DOCS -->
