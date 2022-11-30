<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)

# Terraform Intersight Pools Module

A Terraform module to configure Intersight Pools.

## Note
**This module is not meant for direct use.  Use the Example Module below:**

## Easy IMM

[*Easy IMM - Comprehensive Example*](https://github.com/terraform-cisco-modules/easy-imm-comprehensive-example) - A comprehensive example for policies, pools, and profiles.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | >=1.0.32 |
## Modules

No modules.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model"></a> [model](#input\_model) | Model data. | `any` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Name of the default intersight Organization. | `string` | `"default"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Key/Value Pairs to Assign as Attributes to the Policy. | `list(map(string))` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip"></a> [ip](#output\_ip) | Moids of the IP Pools. |
| <a name="output_iqn"></a> [iqn](#output\_iqn) | Moids of the IQN Pools. |
| <a name="output_mac"></a> [mac](#output\_mac) | Moids of the MAC Pools. |
| <a name="output_orgs"></a> [orgs](#output\_orgs) | Moids of the Account Organizations. |
| <a name="output_resource"></a> [resource](#output\_resource) | Moids of the Resource Pools. |
| <a name="output_uuid"></a> [uuid](#output\_uuid) | Moids of the UUID Pools. |
| <a name="output_wwnn"></a> [wwnn](#output\_wwnn) | Moids of the WWNN Pools. |
| <a name="output_wwpn"></a> [wwpn](#output\_wwpn) | Moids of the WWPN Pools. |
## Resources

| Name | Type |
|------|------|
| [intersight_fcpool_pool.wwnn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_fcpool_pool.wwpn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_ippool_pool.ip](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/ippool_pool) | resource |
| [intersight_iqnpool_pool.iqn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iqnpool_pool) | resource |
| [intersight_macpool_pool.mac](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/macpool_pool) | resource |
| [intersight_resourcepool_pool.resource](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/resourcepool_pool) | resource |
| [intersight_uuidpool_pool.uuid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/uuidpool_pool) | resource |
| [intersight_compute_physical_summary.servers](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/compute_physical_summary) | data source |
| [intersight_organization_organization.orgs](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
<!-- END_TF_DOCS -->