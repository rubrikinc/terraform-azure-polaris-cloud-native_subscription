# Introduction to Terraform

## Log in to Azure
Before running Terraform using the `azurerm_*` or `azapi_*` data sources and resources, authenticating with Azure is
required. [Terraform Module for AzureRM CLI Authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
provides a complete guide on how to authenticate Terraform with Azure.

The following commands can be used from the command line with the [Microsoft Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
tool to manually run Terraform:
```bash
az login --tenant <tenant-id>
```
Where `<tenant-id>` is the ID of the tenant to log in to. If you only have one tenant you can skip the `--tenant`
option. Next, the subscription must be selected. Do this by running the command:
```bash
az account set --subscription <subscription-id>
```
Where `<subscription-id>` is the ID of the Azure subscription to use.

## Initialize the module
The directory can be initialized for Terraform use by running the `terraform init` command:
```
$ terraform init

Initializing the backend...

Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Finding latest version of hashicorp/azurerm...
- Finding latest version of rubrikinc/polaris...
- Installing hashicorp/azurerm v4.22.0...
- Installed hashicorp/azurerm v4.22.0 (signed by HashiCorp)
- Installing rubrikinc/polaris v1.1.0-beta.5...
- Installed rubrikinc/polaris v1.1.0-beta.5 (signed by a HashiCorp partner, key ID 6B41B7EAD9DB76FB)

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
Run `terraform plan` to get information about what will happen when we apply the configuration; this will test that
everything is set up correctly.

## Applying
We can now apply the configuration to add the Azure tenant to RSC using the `terraform apply` command.

## Destroying
Once the subscription no longer needs protection, it can be removed from RSC using the `terraform destroy` command.

## Tips

### Exocompute Details from the Command Line
To specify `exocompute_details` as an environment variable use something like this:
```bash
export TF_VAR_exocompute_details='{"exocompute_config":"{"region":"westus","subnet_name":"subnet1","vnet_name":"vnet1","vnet_resource_group_name":vnet_rg"}}
```
