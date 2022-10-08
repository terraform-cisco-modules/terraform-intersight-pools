<!-- BEGIN_TF_DOCS -->
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ip"></a> [ip](#module\_ip) | terraform-cisco-modules/pools-ip/intersight | >= 1.0.7 |
| <a name="module_iqn"></a> [iqn](#module\_iqn) | terraform-cisco-modules/pools-iqn/intersight | >= 1.0.7 |
| <a name="module_mac"></a> [mac](#module\_mac) | terraform-cisco-modules/pools-mac/intersight | >= 1.0.7 |
| <a name="module_resource"></a> [resource](#module\_resource) | terraform-cisco-modules/pools-resource/intersight | >= 1.0.7 |
| <a name="module_uuid"></a> [uuid](#module\_uuid) | terraform-cisco-modules/pools-uuid/intersight | >= 1.0.7 |
| <a name="module_wwnn"></a> [wwnn](#module\_wwnn) | terraform-cisco-modules/pools-fc/intersight | >= 1.0.7 |
| <a name="module_wwpn"></a> [wwpn](#module\_wwpn) | terraform-cisco-modules/pools-fc/intersight | >= 1.0.7 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model"></a> [model](#input\_model) | Model data. | `any` | n/a | yes |
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
| [intersight_organization_organization.orgs](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
<!-- END_TF_DOCS -->