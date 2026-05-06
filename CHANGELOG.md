# Changelog

## v2.4.0
* Update the version constraint of the `rubrikinc/polaris` provider to `>=1.7.0`.
* Add support for SQL TDE customer-managed keys on the `AZURE_SQL_DB_PROTECTION` feature. When the
  `CNP_AZURE_SQL_DB_TDE_CMK_SUPPORT` RSC feature flag is enabled, a user-assigned managed identity is created and wired
  into the `sql_db_protection` block via the new `user_assigned_managed_identity_*` arguments.
* Add `sql_db_protection_managed_identity_name` input variable, used to name the user-assigned managed identity
  associated with SQL DB protection. Required when the `CNP_AZURE_SQL_DB_TDE_CMK_SUPPORT` feature flag is enabled.

## v2.3.0
* Add `optional_config` block to the `exocompute_details` variable, enabling configuration of advanced Exocompute
  settings such as IP allowlisting, cluster access, cluster tier, disk encryption at host, node count limits, private
  DNS zones, resource group prefix, and user-defined routing.

## v2.2.0
* Update the version constraint of the `rubrikinc/polaris` provider to `>=1.1.6`.
* Add `rsc_features` input variable, used to specify RSC features to enable with permission groups. Exactly one of
  `rsc_features` and `rsc_azure_features` should be specified. If both are specified, `rsc_feature` take precedence.
* Add support for the `CLOUD_NATIVE_BLOB_PROTECTION` RSC feature. Note, this feature requires permission groups to be
  specified.

## v2.1.1
* Remove unnecessary `time_sleep` resources from examples.

## v2.1.0
* Mark `azure_subscription_id` and `polaris_credentials` input variables as deprecated. They are no longer used by the
  module and have no replacements.
* Move example configuration code from the README.md file to the examples directory.
