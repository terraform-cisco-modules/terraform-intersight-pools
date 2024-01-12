<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)

# Terraform Intersight - Pools Module

A Terraform module to configure Intersight Infrastructure Pools.

### NOTE: THIS MODULE IS DESIGNED TO BE CONSUMED USING "EASY IMM"

### A comprehensive example using this module is available below:

## [Easy IMM](https://github.com/terraform-cisco-modules/easy-imm)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.40 |
## Modules

No modules.
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_settings"></a> [global\_settings](#input\_global\_settings) | YAML to HCL Data - global\_settings. | `any` | n/a | yes |
| <a name="input_model"></a> [model](#input\_model) | YAML to HCL Data - model. | `any` | n/a | yes |
| <a name="input_orgs"></a> [orgs](#input\_orgs) | Intersight Organizations Moid Data. | `any` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip"></a> [ip](#output\_ip) | Moids of the IP Pools. |
| <a name="output_ip_reservations"></a> [ip\_reservations](#output\_ip\_reservations) | Moids of the IP Pool Reservations. |
| <a name="output_iqn"></a> [iqn](#output\_iqn) | Moids of the IQN Pools. |
| <a name="output_iqn_reservations"></a> [iqn\_reservations](#output\_iqn\_reservations) | Moids of the IQN Pool Reservations. |
| <a name="output_locals"></a> [locals](#output\_locals) | n/a |
| <a name="output_mac"></a> [mac](#output\_mac) | Moids of the MAC Pools. |
| <a name="output_mac_reservations"></a> [mac\_reservations](#output\_mac\_reservations) | Moids of the MAC Pool Reservations. |
| <a name="output_resource"></a> [resource](#output\_resource) | Moids of the Resource Pools. |
| <a name="output_uuid"></a> [uuid](#output\_uuid) | Moids of the UUID Pools. |
| <a name="output_uuid_reservations"></a> [uuid\_reservations](#output\_uuid\_reservations) | Moids of the UUID Pool Reservations. |
| <a name="output_wwnn"></a> [wwnn](#output\_wwnn) | Moids of the WWNN Pools. |
| <a name="output_wwnn_reservations"></a> [wwnn\_reservations](#output\_wwnn\_reservations) | Moids of the WWNN Pool Reservations. |
| <a name="output_wwpn"></a> [wwpn](#output\_wwpn) | Moids of the WWPN Pools. |
| <a name="output_wwpn_reservations"></a> [wwpn\_reservations](#output\_wwpn\_reservations) | Moids of the WWPN Pool Reservations. |
| <a name="output_z_moids_of_pools_that_were_referenced_in_server_profile_reservations_but_not_already_created"></a> [z\_moids\_of\_pools\_that\_were\_referenced\_in\_server\_profile\_reservations\_but\_not\_already\_created](#output\_z\_moids\_of\_pools\_that\_were\_referenced\_in\_server\_profile\_reservations\_but\_not\_already\_created) | moids of Pools that were referenced in server profiles but not defined |
## Resources

| Name | Type |
|------|------|
| [intersight_fcpool_pool.wwnn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_fcpool_pool.wwnn_data](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_fcpool_pool.wwpn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_fcpool_pool.wwpn_data](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_pool) | resource |
| [intersight_fcpool_reservation.wwnn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_reservation) | resource |
| [intersight_fcpool_reservation.wwpn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/fcpool_reservation) | resource |
| [intersight_ippool_pool.data](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/ippool_pool) | resource |
| [intersight_ippool_pool.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/ippool_pool) | resource |
| [intersight_ippool_reservation.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/ippool_reservation) | resource |
| [intersight_iqnpool_pool.data](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iqnpool_pool) | resource |
| [intersight_iqnpool_pool.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iqnpool_pool) | resource |
| [intersight_iqnpool_reservation.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iqnpool_reservation) | resource |
| [intersight_macpool_pool.data](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/macpool_pool) | resource |
| [intersight_macpool_pool.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/macpool_pool) | resource |
| [intersight_macpool_reservation.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/macpool_reservation) | resource |
| [intersight_resourcepool_pool.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/resourcepool_pool) | resource |
| [intersight_uuidpool_pool.data](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/uuidpool_pool) | resource |
| [intersight_uuidpool_pool.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/uuidpool_pool) | resource |
| [intersight_uuidpool_reservation.map](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/uuidpool_reservation) | resource |
| [intersight_compute_physical_summary.servers](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/compute_physical_summary) | data source |
<!-- END_TF_DOCS -->