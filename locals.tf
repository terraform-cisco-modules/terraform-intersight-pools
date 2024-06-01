locals {
  #____________________________________________________________
  #
  # local defaults and name suffix/prefix
  #____________________________________________________________
  defaults = yamldecode(file("${path.module}/defaults.yaml")).pools
  model    = { for org in local.org_keys : org => lookup(var.model[org], "pools", {}) }
  name_prefix = { for org in local.org_keys : org => {
    for e in local.pool_type : e => lookup(lookup(local.model[org], "name_prefix", {}
    ), e, lookup(lookup(local.model[org], "name_prefix", local.defaults.name_prefix), "default", ""))
  } }
  name_suffix = { for org in local.org_keys : org => {
    for e in local.pool_type : e => lookup(lookup(local.model[org], "name_suffix", {}
    ), e, lookup(lookup(local.model[org], "name_suffix", local.defaults.name_suffix), "default", ""))
  } }
  npfx = { for org in keys(var.orgs) : org => {
    for e in local.pool_type : e => lookup(lookup(lookup(local.model, org, {}), "name_prefix", {}
    ), e, lookup(lookup(lookup(local.model, org, {}), "name_prefix", local.defaults.name_prefix), "default", ""))
  } }
  nsfx = { for org in keys(var.orgs) : org => {
    for e in local.pool_type : e => lookup(lookup(lookup(local.model, org, {}), "name_suffix", {}
    ), e, lookup(lookup(lookup(local.model, org, {}), "name_suffix", local.defaults.name_suffix), "default", ""))
  } }
  org_keys  = sort(keys(var.model))
  org_names = merge({ for k, v in var.orgs : v => k }, jsondecode("{\"5ddfd9ff6972652d31ee6582\":\"x_cisco_intersight_internal\"}"))
  pool_type = ["ip", "iqn", "mac", "resource", "uuid", "wwnn", "wwpn"]

  #____________________________________________________________
  #
  # Intersight IP Pool
  # GUI Location: Pools > Create Pool: IP
  #____________________________________________________________
  ip = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "ip", []) : merge(local.defaults.ip, v, {
      ipv4_blocks = [for e in lookup(v, "ipv4_blocks", []) : merge(local.defaults.ip.ipv4_blocks, e)]
      ipv4_config = [for e in [lookup(v, "ipv4_configuration", {})
      ] : merge(local.defaults.ip.ipv4_configuration, e) if length(lookup(v, "ipv4_configuration", {})) > 0]
      ipv6_blocks = [for e in lookup(v, "ipv6_blocks", []) : merge(local.defaults.ip.ipv6_blocks, e)]
      ipv6_config = [for e in [lookup(v, "ipv6_configuration", {})
      ] : merge(local.defaults.ip.ipv6_configuration, e) if length(lookup(v, "ipv6_configuration", {})) > 0]
      name = "${local.name_prefix[org].ip}${v.name}${local.name_suffix[org].ip}"
      org  = org
      tags = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "ip", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight IQN Pool
  # GUI Location: Pools > Create Pool: IQN
  #____________________________________________________________
  iqn = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "iqn", []) : merge(local.defaults.iqn, v, {
      iqn_blocks = [for e in lookup(v, "iqn_blocks", []) : merge(local.defaults.iqn.iqn_blocks, e)]
      name       = "${local.name_prefix[org].iqn}${v.name}${local.name_suffix[org].iqn}"
      org        = org
      tags       = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "iqn", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight MAC Pool
  # GUI Location: Pools > Create Pool: MAC
  #____________________________________________________________
  mac = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "mac", []) : merge(local.defaults.mac, v, {
      mac_blocks = [for e in lookup(v, "mac_blocks", []) : merge(local.defaults.mac.mac_blocks, e)]
      name       = "${local.name_prefix[org].mac}${v.name}${local.name_suffix[org].mac}"
      org        = org
      tags       = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "mac", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight Pool - Reservations
  #____________________________________________________________
  reservations_loop_1 = flatten([for org in local.org_keys : [
    for r in flatten([for v in flatten([for e in lookup(lookup(var.model[org], "profiles", {}), "server", []
      ) : e.targets if lookup(e, "ignore_reservations", true) == false]) : lookup(v, "reservations", [])]
      ) : merge(local.defaults.reservations, r, {
        org       = length(regexall("/", r.pool_name)) > 0 ? element(split("/", r.pool_name), 0) : org
        pool_name = length(regexall("/", r.pool_name)) > 0 ? element(split("/", r.pool_name), 1) : r.pool_name
    })
  ]])
  reservations = [for v in local.reservations_loop_1 : merge(v, {
    pool_name = "${v.org}/${local.npfx[v.org][v.identity_type]}${v.pool_name}${local.nsfx[v.org][v.identity_type]}"
  })]
  reservation = {
    ip   = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "ip"]))
    iqn  = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "iqn"]))
    mac  = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "mac"]))
    uuid = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "uuid"]))
    wwnn = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "wwnn"]))
    wwpn = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "wwpn"]))
  }
  pools = {
    ip   = { moids = keys(local.ip), object = "ippool.Pool" }
    iqn  = { moids = keys(local.iqn), object = "iqnpool.Pool" }
    mac  = { moids = keys(local.mac), object = "macpool.Pool" }
    uuid = { moids = keys(local.uuid), object = "uuidpool.Pool" }
    wwnn = { moids = keys(local.wwnn), object = "fcpool.Pool" }
    wwpn = { moids = keys(local.wwpn), object = "fcpool.Pool" }
  }
  pool_types = ["ip", "iqn", "mac", "uuid", "wwnn", "wwpn"]
  data_pools = { for e in local.pool_types : e => [for v in local.reservation[e] : element(split("/", v), 1
  ) if contains(local.pools[e].moids, v) == false] }
  pools_data = { for k in keys(data.intersight_search_search_item.pools) : k => {
    for e in lookup(data.intersight_search_search_item.pools[k], "results", []
      ) : "${local.org_names[jsondecode(e.additional_properties).Organization.Moid]}/${jsondecode(e.additional_properties).Name}" => merge({
        additional_properties = jsondecode(e.additional_properties)
        moid                  = e.moid
    })
  } }
  reservation_results = {
    ip   = { for v in sort(keys(intersight_ippool_reservation.map)) : v => intersight_ippool_reservation.map[v].moid }
    iqn  = { for v in sort(keys(intersight_iqnpool_reservation.map)) : v => intersight_iqnpool_reservation.map[v].moid }
    mac  = { for v in sort(keys(intersight_macpool_reservation.map)) : v => intersight_macpool_reservation.map[v].moid }
    uuid = { for v in sort(keys(intersight_uuidpool_reservation.map)) : v => intersight_uuidpool_reservation.map[v].moid }
    wwnn = { for v in sort(keys(intersight_fcpool_reservation.wwnn)) : v => intersight_fcpool_reservation.wwnn[v].moid }
    wwpn = { for v in sort(keys(intersight_fcpool_reservation.wwpn)) : v => intersight_fcpool_reservation.wwpn[v].moid }
  }

  #____________________________________________________________
  #
  # Intersight Resource Pool
  # GUI Location: Pools > Create Pool: Resource
  #____________________________________________________________
  resource = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "resource", []) : merge(local.defaults.resource, v, {
      name               = "${local.name_prefix[org].resource}${v.name}${local.name_suffix[org].resource}"
      org                = org
      serial_number_list = v.serial_number_list
      tags               = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "resource", [])) > 0]) : "${i.org}/${i.name}" => i }
  serial_number_list = flatten([for k, v in local.resource : v.serial_number_list])

  #____________________________________________________________
  #
  # Intersight UUID Pool
  # GUI Location: Pools > Create Pool: UUID
  #____________________________________________________________
  uuid = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "uuid", []) : merge(local.defaults.uuid, v, {
      name        = "${local.name_prefix[org].uuid}${v.name}${local.name_suffix[org].uuid}"
      org         = org
      tags        = lookup(v, "tags", var.global_settings.tags)
      uuid_blocks = [for e in lookup(v, "uuid_blocks", []) : merge(local.defaults.uuid.uuid_blocks, e)]
    })
  ] if length(lookup(local.model[org], "uuid", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight WWNN Pool
  # GUI Location: Pools > Create Pool: WWNN
  #____________________________________________________________
  wwnn = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "wwnn", []) : merge(local.defaults.wwnn, v, {
      id_blocks = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwnn.id_blocks, e)]
      name      = "${local.name_prefix[org].wwnn}${v.name}${local.name_suffix[org].wwnn}"
      org       = org
      tags      = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "wwnn", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight WWPN Pool
  # GUI Location: Pools > Create Pool: WWPN
  #____________________________________________________________
  wwpn = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "wwpn", []) : merge(local.defaults.wwpn, v, {
      id_blocks = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwpn.id_blocks, e)]
      name      = "${local.name_prefix[org].wwpn}${v.name}${local.name_suffix[org].wwpn}"
      org       = org
      tags      = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "wwpn", [])) > 0]) : "${i.org}/${i.name}" => i }
}
