# Terraform Module - Azure Rubrik Cloud Native Subscription

This module adds an Azure subscription to Rubrik Security Cloud (RSC/Polaris) using an existing Azure tenant. It is designed to be used with the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module. 

## Prerequisites

There are a few services you'll need in order to get this project off the ground:

- [Terraform](https://www.terraform.io/downloads.html) v1.5.1 or greater
- [Rubrik Polaris Provider for Terraform](https://github.com/rubrikinc/terraform-provider-polaris) - provides Terraform functions for Rubrik Security Cloud (Polaris)
- [Install the Azure CLI tools](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) - Needed for Terraform to authenticate with Azure
- Properly configure the backend for this module. See [Configure the Backend](#configure-the-backend) in this [README.md](README.md). 

## Usage

```hcl
# Add a single subscription

module "polaris-azure-cloud-native_tenant" {
  source                          = "rubrikinc/polaris-cloud-native_tenant/azure"
  
  azure_tenant_id                 = "abcdef01-2345-6789-abcd-ef0123456789"
  polaris_credentials             = "../.creds/customer-service-account.json"
}

module "polaris-azure-cloud-native_subscription" {
  source                              = "rubrikinc/polaris-cloud-native_subscription/azure"
  
  azure_service_principal_object_id   = module.polaris-azure-cloud-native_tenant.azure_service_principal_object_id
  azure_subscription_id               = "01234567-99ab-cdef-0123-456789abcdef"
  enable_cloud_native_protection      = true
  enable_exocompute                   = true
  exocompute_details                  = {
    exocompute_config_1 = {
      region                    = "westus2"
      subnet_name               = "subnet1"
      vnet_name                 = "vnet1"
      vnet_resource_group_name  = "vnet-rg"
    }
  }
  polaris_credentials                 = "../.creds/customer-service-account.json"
  regions_to_protect                  = ["westus","westus2","eastus"]
  rsc_service_principal_tenant_domain = module.polaris-azure-cloud-native_tenant.rsc_service_principal_tenant_domain
}
```

```hcl
# Add a multiple subscriptions in the same tenant with multiple regions for Exocompute

module "polaris-azure-cloud-native_tenant" {
  source                          = "rubrikinc/polaris-cloud-native_tenant/azure"
  
  azure_tenant_id                 = "abcdef01-2345-6789-abcd-ef0123456789"
  polaris_credentials             = "../.creds/customer-service-account.json"
}

module "polaris-azure-cloud-native_subscription_1" {
  source  = "rubrikinc/polaris-cloud-native_subscription/azure"
  
  azure_service_principal_object_id   = module.polaris-azure-cloud-native_tenant.azure_service_principal_object_id
  azure_subscription_id               = "01234567-99ab-cdef-0123-456789abcdef"
  enable_cloud_native_protection      = true
  enable_exocompute                   = true
  exocompute_details                  = {
    exocompute_config_1 = {
      region                    = "westus2"
      subnet_name               = "subnet1"
      vnet_name                 = "vnet1"
      vnet_resource_group_name  = "vnet-rg"
    }
  }
  polaris_credentials                 = "../.creds/customer-service-account.json"
  regions_to_protect                  = ["westus","westus2","eastus"]
  rsc_service_principal_tenant_domain = module.polaris-azure-cloud-native_tenant.rsc_service_principal_tenant_domain
}

module "polaris-azure-cloud-native_subscription_2" {
  source                              = "rubrikinc/polaris-cloud-native_subscription/azure"
  
  azure_service_principal_object_id   = module.polaris-azure-cloud-native_tenant.azure_service_principal_object_id
  azure_subscription_id               = "01234567-99ab-cdef-fedc-ba987654"
  enable_cloud_native_protection      = true
  enable_exocompute                   = true
  exocompute_details                  = {
    exocompute_config_1 = {
      region                    = "eastus"
      subnet_name               = "subnet2"
      vnet_name                 = "vnet2"
      vnet_resource_group_name  = "vnet2-rg"
    }
    exocompute_config_2 = {
      region                    = "westus"
      subnet_name               = "subnet3"
      vnet_name                 = "vnet3"
      vnet_resource_group_name  = "vnet3-rg"
    }
  }
  polaris_credentials                 = "../.creds/customer-service-account.json"
  regions_to_protect                  = ["westus","westus2","eastus"]
  rsc_service_principal_tenant_domain = module.polaris-azure-cloud-native_tenant.rsc_service_principal_tenant_domain
}

```

<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.97.1 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | 0.7.7 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.cloud_native_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.exocompute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.cloud_native_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.exocompute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [polaris_azure_exocompute.polaris](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_exocompute) | resource |
| [polaris_azure_subscription.cloud_native_protection](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_subscription) | resource |
| [polaris_azure_subscription.polaris](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_subscription) | resource |
| [azurerm_subnet.polaris](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [polaris_azure_permissions.cloud_native_protection](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/azure_permissions) | data source |
| [polaris_azure_permissions.exocompute](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/azure_permissions) | data source |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_service_principal_object_id"></a> [azure\_service\_principal\_object\_id](#input\_azure\_service\_principal\_object\_id) | Azure service principal object id. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription id. | `string` | n/a | yes |
| <a name="input_delete_snapshots_on_destroy"></a> [delete\_snapshots\_on\_destroy](#input\_delete\_snapshots\_on\_destroy) | Should snapshots be deleted when the resource is destroyed. | `bool` | `false` | no |
| <a name="input_enable_cloud_native_protection"></a> [enable\_cloud\_native\_protection](#input\_enable\_cloud\_native\_protection) | Enable cloud native protection for Azure VMs. | `bool` | n/a | yes |
| <a name="input_enable_exocompute"></a> [enable\_exocompute](#input\_enable\_exocompute) | Enable Exocompute for the subscription. | `bool` | n/a | yes |
| <a name="input_exocompute_details"></a> [exocompute\_details](#input\_exocompute\_details) | Region and subnet pair to run Exocompute in. | <pre>map(object({<br>    region                   = string<br>    subnet_name              = string<br>    vnet_name                = string<br>    vnet_resource_group_name = string<br>  }))</pre> | `{}` | no |
| <a name="input_polaris_credentials"></a> [polaris\_credentials](#input\_polaris\_credentials) | Full path to credentials file for RSC/Polaris. | `string` | n/a | yes |
| <a name="input_regions_to_protect"></a> [regions\_to\_protect](#input\_regions\_to\_protect) | List of regions to protect. | `list(string)` | n/a | yes |
| <a name="input_rsc_service_principal_tenant_domain"></a> [rsc\_service\_principal\_tenant\_domain](#input\_rsc\_service\_principal\_tenant\_domain) | Tenant domain of the Service Principal created in RSC. | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->

## Configure the Backend

This module is designed to use a shared backend with the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module. By default it uses a `terraform.tfstate` file that is provided by running the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module first. The `path_to_tenant_state_file` variable should be set to point to the `terraform.tfstate` file which was created by the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module.

The reason to use a remote state between these two modules is to allow a workflow where each subscription maintains its own state file in Terraform. This module can then be added to an existing Terraform script that configures the subscription. The architecture for RSC dictates that a single service principal in a tenant service multiple subscriptions. There for the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) only needs to be run once to create the service principal that each subscription under the tenant will use. 

A better best practice is to configure this module and the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module to use a remote backend. To do so in this module the `data "terraform_remote_state" "polaris"` resource in the [main.tf](main.tf) file will need to be reconfigured for the preferred remote backend. This will need to match the remote backend that is used in the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module. See [Backend Configuration}(https://developer.hashicorp.com/terraform/language/settings/backends/configuration) for more information about configuring remote backends.

## Login to Azure

Before running Terraform using the `azurerm_*` or `azapi_*` data sources and resources, an authentication with Azure is required. [Terraform Module for AzureRM CLI Authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
provides a complete guide on how to authenticate Terraform with Azure. The following commands can be used from a command line interface with the [Microsoft Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
to manually run Terraform:

`az login --tenant <tenant_id>`

Where <tenant_id> is the ID of the tenant to login to. If you only have one tenant you can remove the `--tenant` option.

Next before running this module, the subscription must be selected. Do this by running the command:

`az account set --subscription <subscription_id>`

Where <subscription_id> is the ID of the subscription where CCES will be deployed.

## Initialize the Directory

The directory can be initialized for Terraform use by running the `terraform init` command:

```none
-> terraform init                                                                                                 

Initializing the backend...

Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Finding latest version of hashicorp/azurerm...
- Finding latest version of rubrikinc/polaris...
- Installing hashicorp/azurerm v3.76.0...
- Installed hashicorp/azurerm v3.76.0 (signed by HashiCorp)
- Installing rubrikinc/polaris v0.7.2...
- Installed rubrikinc/polaris v0.7.2 (signed by a HashiCorp partner, key ID 6B41B7EAD9DB76FB)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Planning

Run `terraform plan` to get information about what will happen when we apply the configuration; this will test that everything is set up correctly.

## Applying

We can now apply the configuration to add the Azure subscription to RSC using the `terraform apply` command.


## Destroying

Once the subscription no longer needs protection, it can be removed from RSC using the `terraform destroy` command, and entering `yes` when prompted.

## Tips

### Exocompute Details from the Command Line

To specify `exocompute_details` as an environment variable use something like this:

```none
export TF_VAR_exocompute_details='{"exocompute_config_1":"{"region":"westus","subnet_name":"subnet1","vnet_name":"vnet1","vnet_resource_group_name":vnet_rg"}}
```

### Removing the last subscription from RSC for a tenant.

If you remove the last subscription from RSC for a tenant, the tenant will also be removed from RSC. To add another subscription for the tenant, the tenant will have to be added back again.

## Troubleshooting:

### Missing Tenant

You may receive the following error when applying the Terraform plan:

```none
╷
│ Error: failed to add subscription: failed to request addAzureCloudAccountWithoutOauth: graphql response body is an error (status code 200): NOT_FOUND: Failed to get service principal in the tenant. Azure may take some time to sync service principal. Please try after a minute (Azure error: [Unknown] Unknown service error) (code: 404, traceId: T908tqj5/shh8TMK9rX2lA==)
│ 
│   with polaris_azure_subscription.polaris,
│   on main.tf line 84, in resource "polaris_azure_subscription" "polaris":
│   84: resource "polaris_azure_subscription" "polaris" {
│ 
```

If this happens, it's likely due to the last subscription in a tenant being removed from RSC, but the `terraform.tfstate` file remains from the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module. In this case when the last subscription was removed from RSC, the tenant was automatically removed by RSC. To solve this, re-run the [Terraform Module - Azure Rubrik Cloud Native Tenant](https://github.com/rubrikinc/terraform-azure-polaris-cloud-native_tenant) module to create a new service principal. 

## How You Can Help

We glady welcome contributions from the community. From updating the documentation to adding more functionality, all ideas are welcome. Thank you in advance for all of your issues, pull requests, and comments!

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## Developers

This [README.md](README.md) was created with [terraform-docs](https://github.com/terraform-docs/terraform-docs). To update any of the auto generated parameters between the `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` lines first modify the [.terraform-docs.yml](.terraform-docs.yml) file, if needed. Then run [gen_docs.sh](gen_docs.sh) in this modules directory. For any documentation that needs to be modified outside of the `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` lines, modify this [README.md](README.md) file directly.

## License

- [MIT License](LICENSE)
