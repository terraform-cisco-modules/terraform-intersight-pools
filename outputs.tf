#__________________________________________________________
#
# Data Object Outputs
#__________________________________________________________

output "data_policies" {
  description = "Moid's of the Policies that were not defined locally."
  value       = { for e in sort(keys(local.policies_data)) : e => { for k, v in local.policies_data[e] : k => v.moid } }
}

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
  value       = { for k, v in intersight_ippool_pool.map : k => v.moid }
}
output "iqn" {
  description = "Moids of the IQN Pools."
  value       = { for k, v in intersight_iqnpool_pool.map : k => v.moid }
}
output "mac" {
  description = "Moids of the MAC Pools."
  value       = { for k, v in intersight_macpool_pool.map : k => v.moid }
}
output "resource" {
  description = "Moids of the Resource Pools."
  value       = { for k, v in intersight_resourcepool_pool.map : k => v.moid }
}
output "uuid" {
  description = "Moids of the UUID Pools."
  value       = { for k, v in intersight_uuidpool_pool.map : k => v.moid }
}
output "wwnn" {
  description = "Moids of the WWNN Pools."
  value       = { for k, v in intersight_fcpool_pool.wwnn : k => v.moid }
}
output "wwpn" {
  description = "Moids of the WWPN Pools."
  value       = { for k, v in intersight_fcpool_pool.wwpn : k => v.moid }
}

#__________________________________________________________
#
# Server Pool Qualification Policy
#__________________________________________________________

output "server_pool_qualification" {
  description = "Moids of the Server Pool Qualfication Policies."
  value       = { for k, v in intersight_resourcepool_qualification_policy.map : k => v.moid }
}

#__________________________________________________________
#
# Reservation Outputs
#__________________________________________________________

output "reservations" {
  description = "Moids of the Pool Reservations."
  value       = { for k in keys(local.reservation_results) : k => local.reservation_results[k] if length(local.reservation_results[k]) > 0 }
}
