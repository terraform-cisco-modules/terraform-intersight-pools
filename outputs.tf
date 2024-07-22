#__________________________________________________________
#
# Data Object Outputs
#__________________________________________________________

output "data_pools" {
  description = "Moid's of the Pools that were not defined locally."
  value       = { for e in sort(keys(local.pools_data)) : e => { for k, v in local.pools_data[e] : k => v.moid } }
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
  value       = { for k in keys(local.reservation_results) : k => local.reservation_results[k] if length(local.reservation_results[k]) > 0 }
}
