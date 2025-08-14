# Changelog

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
