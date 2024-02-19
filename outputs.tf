output "ip" {
  description = "Moids of the IP Pools."
  value       = { for v in sort(keys(intersight_ippool_pool.map)) : v => intersight_ippool_pool.map[v].moid }
}

output "ip_reservations" {
  description = "Moids of the IP Pool Reservations."
  value       = { for v in sort(keys(intersight_ippool_reservation.map)) : v => intersight_ippool_reservation.map[v].moid }
}

output "iqn" {
  description = "Moids of the IQN Pools."
  value       = { for v in sort(keys(intersight_iqnpool_pool.map)) : v => intersight_iqnpool_pool.map[v].moid }
}

output "iqn_reservations" {
  description = "Moids of the IQN Pool Reservations."
  value       = { for v in sort(keys(intersight_iqnpool_reservation.map)) : v => intersight_iqnpool_reservation.map[v].moid }
}

#output "locals" {
#  value = {
#    ip   = concat([for k, v in local.ip : k], [for v in local.reservation_ip_pools : v if lookup(local.ip, v, "#NOEXIST") == "#NOEXIST"])
#    iqn  = concat([for k, v in local.iqn : k], [for v in local.reservation_iqn_pools : v if lookup(local.iqn, v, "#NOEXIST") == "#NOEXIST"])
#    mac  = concat([for k, v in local.mac : k], [for v in local.reservation_mac_pools : v if lookup(local.mac, v, "#NOEXIST") == "#NOEXIST"])
#    uuid = concat([for k, v in local.uuid : k], [for v in local.reservation_uuid_pools : v if lookup(local.uuid, v, "#NOEXIST") == "#NOEXIST"])
#    wwnn = concat([for k, v in local.wwnn : k], [for v in local.reservation_wwnn_pools : v if lookup(local.wwnn, v, "#NOEXIST") == "#NOEXIST"])
#    wwpn = concat([for k, v in local.wwpn : k], [for v in local.reservation_wwpn_pools : v if lookup(local.wwpn, v, "#NOEXIST") == "#NOEXIST"])
#  }
#}
output "mac" {
  description = "Moids of the MAC Pools."
  value       = { for v in sort(keys(intersight_macpool_pool.map)) : v => intersight_macpool_pool.map[v].moid }
}

output "mac_reservations" {
  description = "Moids of the MAC Pool Reservations."
  value       = { for v in sort(keys(intersight_macpool_reservation.map)) : v => intersight_macpool_reservation.map[v].moid }
}

output "resource" {
  description = "Moids of the Resource Pools."
  value       = { for v in sort(keys(intersight_resourcepool_pool.map)) : v => intersight_resourcepool_pool.map[v].moid }
}

output "uuid" {
  description = "Moids of the UUID Pools."
  value       = { for v in sort(keys(intersight_uuidpool_pool.map)) : v => intersight_uuidpool_pool.map[v].moid }
}

output "uuid_reservations" {
  description = "Moids of the UUID Pool Reservations."
  value       = { for v in sort(keys(intersight_uuidpool_reservation.map)) : v => intersight_uuidpool_reservation.map[v].moid }
}

output "wwnn" {
  description = "Moids of the WWNN Pools."
  value       = { for v in sort(keys(intersight_fcpool_pool.wwnn)) : v => intersight_fcpool_pool.wwnn[v].moid }
}

output "wwnn_reservations" {
  description = "Moids of the WWNN Pool Reservations."
  value       = { for v in sort(keys(intersight_fcpool_reservation.wwnn)) : v => intersight_fcpool_reservation.wwnn[v].moid }
}

output "wwpn" {
  description = "Moids of the WWPN Pools."
  value       = { for v in sort(keys(intersight_fcpool_pool.wwpn)) : v => intersight_fcpool_pool.wwpn[v].moid }
}

output "wwpn_reservations" {
  description = "Moids of the WWPN Pool Reservations."
  value       = { for v in sort(keys(intersight_fcpool_reservation.wwpn)) : v => intersight_fcpool_reservation.wwpn[v].moid }
}

output "z_moids_of_pools_that_were_referenced_in_server_profile_reservations_but_not_already_created" {
  description = "moids of Pools that were referenced in server profiles but not defined"
  value = lookup(var.global_settings, "debugging", false) == true ? {
    ip   = { for v in sort(keys(intersight_ippool_pool.data)) : v => intersight_ippool_pool.data[v].moid }
    iqn  = { for v in sort(keys(intersight_iqnpool_pool.data)) : v => intersight_iqnpool_pool.data[v].moid }
    mac  = { for v in sort(keys(intersight_macpool_pool.data)) : v => intersight_macpool_pool.data[v].moid }
    uuid = { for v in sort(keys(intersight_uuidpool_pool.data)) : v => intersight_uuidpool_pool.data[v].moid }
    wwnn = { for v in sort(keys(intersight_fcpool_pool.wwnn_data)) : v => intersight_fcpool_pool.wwnn_data[v].moid }
    wwpn = { for v in sort(keys(intersight_fcpool_pool.wwpn_data)) : v => intersight_fcpool_pool.wwpn_data[v].moid }
  } : {}
}
