locals {
  defaults = yamldecode(file("${path.module}/defaults.yaml")).pools
  name_prefix = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in [lookup(lookup(var.model[org], "pools", {}), "name_prefix", local.defaults.name_prefix)] : {
      ip       = v.ip != "" ? v.ip : v.default
      iqn      = v.iqn != "" ? v.iqn : v.default
      mac      = v.mac != "" ? v.mac : v.default
      org      = org
      resource = v.resource != "" ? v.resource : v.default
      uuid     = v.uuid != "" ? v.uuid : v.default
      wwnn     = v.wwnn != "" ? v.wwnn : v.default
      wwpn     = v.wwpn != "" ? v.wwpn : v.default
    }
  ]]) : i.org => i }
  name_suffix = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in [lookup(lookup(var.model[org], "pools", {}), "name_suffix", local.defaults.name_suffix)] : {
      ip       = v.ip != "" ? v.ip : v.default
      iqn      = v.iqn != "" ? v.iqn : v.default
      mac      = v.mac != "" ? v.mac : v.default
      org      = org
      resource = v.resource != "" ? v.resource : v.default
      uuid     = v.uuid != "" ? v.uuid : v.default
      wwnn     = v.wwnn != "" ? v.wwnn : v.default
      wwpn     = v.wwpn != "" ? v.wwpn : v.default
    }
  ]]) : i.org => i }
  orgs = var.orgs

  #____________________________________________________________
  #
  # Intersight IP Pool
  # GUI Location: Pools > Create Pool: IP
  #____________________________________________________________
  ip = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in lookup(lookup(var.model[org], "pools", {}), "ip", []) : merge(local.defaults.ip, v, {
      ipv4_blocks = [for e in lookup(v, "ipv4_blocks", []) : merge(local.defaults.ip.ipv4_blocks, e)]
      ipv4_config = [for e in [lookup(v, "ipv4_configuration", {})
      ] : merge(local.defaults.ip.ipv4_configuration, e) if length(lookup(v, "ipv4_configuration", {})) > 0]
      ipv6_blocks = [for e in lookup(v, "ipv6_blocks", []) : merge(local.defaults.ip.ipv6_blocks, e)]
      ipv6_config = [for e in [lookup(v, "ipv6_configuration", {})
      ] : merge(local.defaults.ip.ipv6_configuration, e) if length(lookup(v, "ipv6_configuration", {})) > 0]
      name         = "${local.name_prefix[org].ip}${v.name}${local.name_suffix[org].ip}"
      organization = org
      tags         = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(lookup(var.model[org], "pools", {}), "ip", [])) > 0]) : "${i.organization}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight IQN Pool
  # GUI Location: Pools > Create Pool: IQN
  #____________________________________________________________
  iqn = { for i in flatten([
    for org in sort(keys(var.model)) : [
      for v in lookup(lookup(var.model[org], "pools", {}), "iqn", []) : merge(local.defaults.iqn, v, {
        iqn_blocks   = [for e in lookup(v, "iqn_blocks", []) : merge(local.defaults.iqn.iqn_blocks, e)]
        name         = "${local.name_prefix[org].iqn}${v.name}${local.name_suffix[org].iqn}"
        organization = org
        tags         = lookup(v, "tags", var.global_settings.tags)
      })
  ] if length(lookup(lookup(var.model[org], "pools", {}), "iqn", [])) > 0]) : "${i.organization}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight MAC Pool
  # GUI Location: Pools > Create Pool: MAC
  #____________________________________________________________
  mac = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in lookup(lookup(var.model[org], "pools", {}), "mac", []) : merge(local.defaults.mac, v, {
      mac_blocks   = [for e in lookup(v, "mac_blocks", []) : merge(local.defaults.mac.mac_blocks, e)]
      name         = "${local.name_prefix[org].mac}${v.name}${local.name_suffix[org].mac}"
      organization = org
      tags         = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(lookup(var.model[org], "pools", {}), "mac", [])) > 0]) : "${i.organization}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight Pool - Reservations
  #____________________________________________________________
  reservations = flatten([for org in sort(keys(var.model)) : [
    for r in flatten([for v in flatten([for e in lookup(lookup(var.model[org], "profiles", {}), "server", []) : e.targets if lookup(e, "ignore_reservations", true) == false]) : lookup(v, "reservations", [])]
      ) : merge(local.defaults.reservations, r, {
        combined     = length(regexall("/", r.pool_name)) > 0 ? r.pool_name : "${org}/${r.pool_name}"
        organization = length(regexall("/", r.pool_name)) > 0 ? element(split("/", r.pool_name), 0) : org
        pool_name    = length(regexall("/", r.pool_name)) > 0 ? element(split("/", r.pool_name), 1) : r.pool_name
    })
  ]])
  reservation_ip_pools   = distinct(compact([for v in local.reservations : "${v.organization}/${v.pool_name}" if v.identity_type == "ip"]))
  reservation_iqn_pools  = distinct(compact([for v in local.reservations : "${v.organization}/${v.pool_name}" if v.identity_type == "iqn"]))
  reservation_mac_pools  = distinct(compact([for v in local.reservations : "${v.organization}/${v.pool_name}" if v.identity_type == "mac"]))
  reservation_uuid_pools = distinct(compact([for v in local.reservations : "${v.organization}/${v.pool_name}" if v.identity_type == "uuid"]))
  reservation_wwnn_pools = distinct(compact([for v in local.reservations : "${v.organization}/${v.pool_name}" if v.identity_type == "wwnn"]))
  reservation_wwpn_pools = distinct(compact([for v in local.reservations : "${v.organization}/${v.pool_name}" if v.identity_type == "wwpn"]))

  #____________________________________________________________
  #
  # Intersight Resource Pool
  # GUI Location: Pools > Create Pool: Resource
  #____________________________________________________________
  resource = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in lookup(lookup(var.model[org], "pools", {}), "resource", []) : merge(local.defaults.resource, v, {
      name               = "${local.name_prefix[org].resource}${v.name}${local.name_suffix[org].resource}"
      organization       = org
      serial_number_list = v.serial_number_list
      tags               = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(lookup(var.model[org], "pools", {}), "resource", [])) > 0]) : "${i.organization}/${i.name}" => i }
  serial_number_list = flatten([for k, v in local.resource : v.serial_number_list])

  #____________________________________________________________
  #
  # Intersight UUID Pool
  # GUI Location: Pools > Create Pool: UUID
  #____________________________________________________________
  uuid = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in lookup(lookup(var.model[org], "pools", {}), "uuid", []) : merge(local.defaults.uuid, v, {
      uuid_blocks  = [for e in lookup(v, "uuid_blocks", []) : merge(local.defaults.uuid.uuid_blocks, e)]
      name         = "${local.name_prefix[org].uuid}${v.name}${local.name_suffix[org].uuid}"
      organization = org
      prefix       = lookup(v, "prefix", local.defaults.uuid.prefix)
      tags         = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(lookup(var.model[org], "pools", {}), "uuid", [])) > 0]) : "${i.organization}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight WWNN Pool
  # GUI Location: Pools > Create Pool: WWNN
  #____________________________________________________________
  wwnn = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in lookup(lookup(var.model[org], "pools", {}), "wwnn", []) : merge(local.defaults.wwnn, v, {
      id_blocks    = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwnn.id_blocks, e)]
      name         = "${local.name_prefix[org].wwnn}${v.name}${local.name_suffix[org].wwnn}"
      organization = org
      tags         = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(lookup(var.model[org], "pools", {}), "wwnn", [])) > 0]) : "${i.organization}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight WWPN Pool
  # GUI Location: Pools > Create Pool: WWPN
  #____________________________________________________________
  wwpn = { for i in flatten([for org in sort(keys(var.model)) : [
    for v in lookup(lookup(var.model[org], "pools", {}), "wwpn", []) : merge(local.defaults.wwpn, v, {
      assignment_order = lookup(v, "assignment_order", local.defaults.wwpn.assignment_order)
      description      = lookup(v, "description", "")
      id_blocks        = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwpn.id_blocks, e)]
      name             = "${local.name_prefix[org].wwpn}${v.name}${local.name_suffix[org].wwpn}"
      organization     = org
      tags             = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(lookup(var.model[org], "pools", {}), "wwpn", [])) > 0]) : "${i.organization}/${i.name}" => i }
}
