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
