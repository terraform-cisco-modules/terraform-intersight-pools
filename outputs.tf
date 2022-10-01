output "ip" {
  description = "Moid of the IP Pools."
  value = length(lookup(local.pools, "ip", [])) > 0 ? { for v in sort(
    keys(module.ip)
  ) : v => module.ip[v] } : {}
}

output "iqn" {
  description = "Moid of the IQN Pools."
  value = length(lookup(local.pools, "iqn", [])) > 0 ? { for v in sort(
    keys(module.iqn)
  ) : v => module.iqn[v] } : {}
}

output "mac" {
  description = "Moid of the MAC Pools."
  value = length(lookup(local.pools, "mac", [])) > 0 ? { for v in sort(
    keys(module.mac)
  ) : v => module.mac[v] } : {}
}

output "orgs" {
  description = "Moid of the Account Organizations."
  value       = local.orgs
}

output "resource" {
  description = "Moid of the Resource Pools."
  value = length(lookup(local.pools, "resource", [])) > 0 ? { for v in sort(
    keys(module.resource)
  ) : v => module.resource[v] } : {}
}

output "uuid" {
  description = "Moid of the UUID Pools."
  value = length(lookup(local.pools, "uuid", [])) > 0 ? { for v in sort(
    keys(module.uuid)
  ) : v => module.uuid[v] } : {}
}

output "wwnn" {
  description = "Moid of the WWNN Pools."
  value = length(lookup(local.pools, "wwnn", [])) > 0 ? { for v in sort(
    keys(module.wwnn)
  ) : v => module.wwnn[v] } : {}
}

output "wwpn" {
  description = "Moid of the WWPN Pools."
  value = length(lookup(local.pools, "wwpn", [])) > 0 ? { for v in sort(
    keys(module.wwpn)
  ) : v => module.wwpn[v] } : {}
}
