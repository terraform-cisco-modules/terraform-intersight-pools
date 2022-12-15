output "ip" {
  description = "Moids of the IP Pools."
  value = length(local.ip) > 0 ? { for v in sort(
    keys(intersight_ippool_pool.ip)
  ) : v => intersight_ippool_pool.ip[v].moid } : {}
}

output "ip_reservations" {
  description = "Moids of the IP Pool Reservations."
  value = length(local.ip_reservations) > 0 ? { for v in sort(
    keys(intersight_ippool_reservation.ip)
  ) : v => intersight_ippool_reservation.ip[v].moid } : {}
}

output "iqn" {
  description = "Moids of the IQN Pools."
  value = length(local.iqn) > 0 ? { for v in sort(
    keys(intersight_iqnpool_pool.iqn)
  ) : v => intersight_iqnpool_pool.iqn[v].moid } : {}
}

output "iqn_reservations" {
  description = "Moids of the IQN Pool Reservations."
  value = length(local.iqn_reservations) > 0 ? { for v in sort(
    keys(intersight_iqnpool_reservation.iqn)
  ) : v => intersight_iqnpool_reservation.iqn[v].moid } : {}
}

output "mac" {
  description = "Moids of the MAC Pools."
  value = length(local.mac) > 0 ? { for v in sort(
    keys(intersight_macpool_pool.mac)
  ) : v => intersight_macpool_pool.mac[v].moid } : {}
}

output "mac_reservations" {
  description = "Moids of the MAC Pool Reservations."
  value = length(local.mac_reservations) > 0 ? { for v in sort(
    keys(intersight_macpool_reservation.mac)
  ) : v => intersight_macpool_reservation.mac[v].moid } : {}
}

output "orgs" {
  description = "Moids of the Account Organizations."
  value       = local.orgs
}

output "resource" {
  description = "Moids of the Resource Pools."
  value = length(local.resource) > 0 ? { for v in sort(
    keys(intersight_resourcepool_pool.resource)
  ) : v => intersight_resourcepool_pool.resource[v].moid } : {}
}

output "uuid" {
  description = "Moids of the UUID Pools."
  value = length(local.uuid) > 0 ? { for v in sort(
    keys(intersight_uuidpool_pool.uuid)
  ) : v => intersight_uuidpool_pool.uuid[v].moid } : {}
}

output "uuid_reservations" {
  description = "Moids of the UUID Pool Reservations."
  value = length(local.uuid_reservations) > 0 ? { for v in sort(
    keys(intersight_uuidpool_reservation.uuid)
  ) : v => intersight_uuidpool_reservation.uuid[v].moid } : {}
}

output "wwnn" {
  description = "Moids of the WWNN Pools."
  value = length(local.wwnn) > 0 ? { for v in sort(
    keys(intersight_fcpool_pool.wwnn)
  ) : v => intersight_fcpool_pool.wwnn[v].moid } : {}
}

output "wwnn_reservations" {
  description = "Moids of the WWNN Pool Reservations."
  value = length(local.wwnn_reservations) > 0 ? { for v in sort(
    keys(intersight_fcpool_reservation.wwnn)
  ) : v => intersight_fcpool_reservation.wwnn[v].moid } : {}
}

output "wwpn" {
  description = "Moids of the WWPN Pools."
  value = length(local.wwpn) > 0 ? { for v in sort(
    keys(intersight_fcpool_pool.wwpn)
  ) : v => intersight_fcpool_pool.wwpn[v].moid } : {}
}

output "wwpn_reservations" {
  description = "Moids of the WWPN Pool Reservations."
  value = length(local.wwpn_reservations) > 0 ? { for v in sort(
    keys(intersight_fcpool_reservation.wwpn)
  ) : v => intersight_fcpool_reservation.wwpn[v].moid } : {}
}
