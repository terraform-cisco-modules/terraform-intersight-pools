#__________________________________________________________
#
# Data Object Outputs
#__________________________________________________________

output "data_pools" {
  value = { for e in keys(data.intersight_search_search_item.pools) : e => {
    for i in data.intersight_search_search_item.pools[e
    ].results : "${local.org_moids[jsondecode(i.additional_properties).Organization.Moid]}/${jsondecode(i.additional_properties).Name}" => i.moid }
  }
}

#__________________________________________________________
#
# Name Prefix/Suffix Outputs
#__________________________________________________________

output "name_prefix" {
  description = "Name Prefix Outputs."
  value       = local.name_prefix
}
output "name_suffix" {
  description = "Name Suffix Outputs."
  value       = local.name_suffix
}

#__________________________________________________________
#
# Pools Outputs
#__________________________________________________________

output "ip" {
  description = "Moids of the IP Pools."
  value       = { for v in sort(keys(intersight_ippool_pool.map)) : v => intersight_ippool_pool.map[v].moid }
}
output "iqn" {
  description = "Moids of the IQN Pools."
  value       = { for v in sort(keys(intersight_iqnpool_pool.map)) : v => intersight_iqnpool_pool.map[v].moid }
}
output "mac" {
  description = "Moids of the MAC Pools."
  value       = { for v in sort(keys(intersight_macpool_pool.map)) : v => intersight_macpool_pool.map[v].moid }
}
output "resource" {
  description = "Moids of the Resource Pools."
  value       = { for v in sort(keys(intersight_resourcepool_pool.map)) : v => intersight_resourcepool_pool.map[v].moid }
}
output "uuid" {
  description = "Moids of the UUID Pools."
  value       = { for v in sort(keys(intersight_uuidpool_pool.map)) : v => intersight_uuidpool_pool.map[v].moid }
}
output "wwnn" {
  description = "Moids of the WWNN Pools."
  value       = { for v in sort(keys(intersight_fcpool_pool.wwnn)) : v => intersight_fcpool_pool.wwnn[v].moid }
}
output "wwpn" {
  description = "Moids of the WWPN Pools."
  value       = { for v in sort(keys(intersight_fcpool_pool.wwpn)) : v => intersight_fcpool_pool.wwpn[v].moid }
}

#__________________________________________________________
#
# Reservation Outputs
#__________________________________________________________

output "reservations" {
  description = "Moids of the Pool Reservations."
  value       = { for v in local.pool_types : v => local.reservation_results[v] if length(local.reservation_results[v]) > 0 }
}
