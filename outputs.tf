output "ip" {
  description = "Moid of the IP Pools."
  value = lookup(local.modules, "pools_ip", true) ? { for v in sort(
    keys(module.ip)
  ) : v => module.ip[v] } : {}
}

output "iqn" {
  description = "Moid of the IQN Pools."
  value = lookup(local.modules, "pools_iqn", true) ? { for v in sort(
    keys(module.iqn)
  ) : v => module.iqn[v] } : {}
}

output "mac" {
  description = "Moid of the MAC Pools."
  value = lookup(local.modules, "pools_mac", true) ? { for v in sort(
    keys(module.mac)
  ) : v => module.mac[v] } : {}
}

output "resource" {
  description = "Moid of the Resource Pools."
  value = lookup(local.modules, "pools_resource", true) ? { for v in sort(
    keys(module.resource)
  ) : v => module.resource[v] } : {}
}

output "uuid" {
  description = "Moid of the UUID Pools."
  value = lookup(local.modules, "pools_uuid", true) ? { for v in sort(
    keys(module.uuid)
  ) : v => module.uuid[v] } : {}
}

output "wwnn" {
  description = "Moid of the WWNN Pools."
  value = lookup(local.modules, "pools_wwnn", true) ? { for v in sort(
    keys(module.wwnn)
  ) : v => module.wwnn[v] } : {}
}

output "wwpn" {
  description = "Moid of the WWPN Pools."
  value = lookup(local.modules, "pools_wwpn", true) ? { for v in sort(
    keys(module.wwpn)
  ) : v => module.wwpn[v] } : {}
}

