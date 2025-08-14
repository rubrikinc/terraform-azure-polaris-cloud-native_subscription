# Basic Azure Subscription
The configuration in this directory adds an Azure tenant and Azure subscription to RSC.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.1.6 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_polaris_azure_cloud_native_subscription"></a> [polaris\_azure\_cloud\_native\_subscription](#module\_polaris\_azure\_cloud\_native\_subscription) | ../.. | n/a |
| <a name="module_polaris_azure_cloud_native_tenant"></a> [polaris\_azure\_cloud\_native\_tenant](#module\_polaris\_azure\_cloud\_native\_tenant) | rubrikinc/polaris-cloud-native_tenant/azure | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID. | `string` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Azure tenant ID. | `string` | n/a | yes |
| <a name="input_exocompute_details"></a> [exocompute\_details](#input\_exocompute\_details) | Region, VNet, Subnet and pod CIDR for Exocompute. | <pre>map(<br/>    object(<br/>      {<br/>        region                   = string<br/>        pod_overlay_network_cidr = string<br/>        subnet_name              = string<br/>        vnet_name                = string<br/>        vnet_resource_group_name = string<br/>      }<br/>    )<br/>  )</pre> | `{}` | no |
| <a name="input_polaris_credentials"></a> [polaris\_credentials](#input\_polaris\_credentials) | RSC service account credentials or the path to a file containing the service account credentials. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
