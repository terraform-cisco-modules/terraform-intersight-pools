locals {
  defaults = yamldecode(file("${path.module}/defaults.yaml")).pools
  lip      = local.defaults.ip
  name_prefix = [for v in [merge(lookup(var.pools, "name_prefix", {}), local.defaults.name_prefix)] : {
    ip       = v.ip != "" ? v.ip : v.default
    iqn      = v.iqn != "" ? v.iqn : v.default
    mac      = v.mac != "" ? v.mac : v.default
    resource = v.resource != "" ? v.resource : v.default
    uuid     = v.uuid != "" ? v.uuid : v.default
    wwnn     = v.wwnn != "" ? v.wwnn : v.default
    wwpn     = v.wwpn != "" ? v.wwpn : v.default
  }][0]
  name_suffix = [for v in [merge(lookup(var.pools, "name_suffix", {}), local.defaults.name_suffix)] : {
    ip       = v.ip != "" ? v.ip : v.default
    iqn      = v.iqn != "" ? v.iqn : v.default
    mac      = v.mac != "" ? v.mac : v.default
    resource = v.resource != "" ? v.resource : v.default
    uuid     = v.uuid != "" ? v.uuid : v.default
    wwnn     = v.wwnn != "" ? v.wwnn : v.default
    wwpn     = v.wwpn != "" ? v.wwpn : v.default
  }][0]
  orgs = var.pools.orgs

  #____________________________________________________________
  #
  # Intersight IP Pool
  # GUI Location: Pools > Create Pool: IP
  #____________________________________________________________
  ip = {
    for v in lookup(var.pools, "ip", {}) : v.name => merge(local.lip, v, {
      ipv4_blocks = [for e in lookup(v, "ipv4_blocks", []) : merge(local.lip.ipv4_blocks, e)]
      ipv4_config = [for e in [lookup(v, "ipv4_configuration", {})
      ] : merge(local.lip.ipv4_configuration, e) if length(lookup(v, "ipv4_configuration", {})) > 0]
      ipv6_blocks = [for e in lookup(v, "ipv6_blocks", []) : merge(local.lip.ipv6_blocks, e)]
      ipv6_config = [for e in [lookup(v, "ipv6_configuration", {})
      ] : merge(local.lip.ipv6_configuration, e) if length(lookup(v, "ipv6_configuration", {})) > 0]
      name         = "${local.name_prefix.ip}${v.name}${local.name_suffix.ip}"
      reservations = lookup(v, "reservations", {})
      organization = var.pools.organization
      tags         = lookup(v, "tags", var.pools.global_settings.tags)
    })
  }
  ipres = local.defaults.ip.reservations
  ip_reservations = { for i in flatten([
    for key, value in local.ip : [for v in [value.reservations] : [
      for e in lookup(v, "identities", []) : merge(local.ipres, v, {
        identity     = e
        organization = value.organization
        pool_name    = key
      })
    ]]
  ]) : "${i.pool_name}:${i.identity}" => i }

  #____________________________________________________________
  #
  # Intersight IQN Pool
  # GUI Location: Pools > Create Pool: IQN
  #____________________________________________________________
  iqn = {
    for v in lookup(var.pools, "iqn", {}) : v.name => merge(local.defaults.iqn, v, {
      iqn_blocks   = [for e in lookup(v, "iqn_blocks", []) : merge(local.defaults.iqn.iqn_blocks, e)]
      name         = "${local.name_prefix.iqn}${v.name}${local.name_suffix.iqn}"
      organization = var.pools.organization
      reservations = lookup(v, "reservations", {})
      tags         = lookup(v, "tags", var.pools.global_settings.tags)
    })
  }
  iqn_reservations = { for i in flatten([
    for key, value in local.iqn : [for v in [value.reservations] : [
      for s in lookup(v, "identities", []) : merge(local.defaults.iqn.reservations, v, {
        identity     = s
        organization = value.organization
        pool_name    = key
      })
    ]]
  ]) : "${i.pool_name}:${i.identity}" => i }

  #____________________________________________________________
  #
  # Intersight MAC Pool
  # GUI Location: Pools > Create Pool: MAC
  #____________________________________________________________
  mac = {
    for v in lookup(var.pools, "mac", {}) : v.name => merge(local.defaults.mac, v, {
      mac_blocks   = [for e in lookup(v, "mac_blocks", []) : merge(local.defaults.mac.mac_blocks, e)]
      name         = "${local.name_prefix.mac}${v.name}${local.name_suffix.mac}"
      organization = var.pools.organization
      reservations = lookup(v, "reservations", {})
      tags         = lookup(v, "tags", var.pools.global_settings.tags)
    })
  }
  mac_reservations = { for i in flatten([
    for key, value in local.mac : [for v in [value.reservations] : [
      for s in lookup(v, "identities", []) : merge(local.defaults.mac.reservations, v, {
        identity     = s
        organization = value.organization
        pool_name    = key
      })
    ]]
  ]) : "${i.pool_name}:${i.identity}" => i }

  #____________________________________________________________
  #
  # Intersight Resource Pool
  # GUI Location: Pools > Create Pool: Resource
  #____________________________________________________________
  resource = {
    for v in lookup(var.pools, "resource", {}) : v.name => merge(local.defaults.resource, v, {
      name               = "${local.name_prefix.resource}${v.name}${local.name_suffix.resource}"
      organization       = var.pools.organization
      serial_number_list = v.serial_number_list
      tags               = lookup(v, "tags", var.pools.global_settings.tags)
    })
  }
  serial_number_list = flatten([for v in local.resource : v.serial_number_list])

  #____________________________________________________________
  #
  # Intersight UUID Pool
  # GUI Location: Pools > Create Pool: UUID
  #____________________________________________________________
  uuid = {
    for v in lookup(var.pools, "uuid", {}) : v.name => merge(local.defaults.uuid, v, {
      uuid_blocks  = [for e in lookup(v, "uuid_blocks", []) : merge(local.defaults.uuid.uuid_blocks, e)]
      name         = "${local.name_prefix.uuid}${v.name}${local.name_suffix.uuid}"
      organization = var.pools.organization
      prefix       = lookup(v, "prefix", local.defaults.uuid.prefix)
      reservations = lookup(v, "reservations", {})
      tags         = lookup(v, "tags", var.pools.global_settings.tags)
    })
  }
  uuid_reservations = { for i in flatten([
    for key, value in local.uuid : [for v in [value.reservations] : [
      for s in lookup(v, "identities", []) : merge(local.defaults.uuid.reservations, v, {
        identity     = s
        organization = value.organization
        pool_name    = key
      })
    ]]
  ]) : "${i.pool_name}:${i.identity}" => i }


  #____________________________________________________________
  #
  # Intersight WWNN Pool
  # GUI Location: Pools > Create Pool: WWNN
  #____________________________________________________________
  wwnn = {
    for v in lookup(var.pools, "wwnn", {}) : v.name => merge(local.defaults.wwnn, v, {
      id_blocks    = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwnn.id_blocks, e)]
      name         = "${local.name_prefix.wwnn}${v.name}${local.name_suffix.wwnn}"
      organization = var.pools.organization
      reservations = lookup(v, "reservations", {})
      tags         = lookup(v, "tags", var.pools.global_settings.tags)
    })
  }
  wwnn_reservations = { for i in flatten([
    for key, value in local.wwnn : [for v in [value.reservations] : [
      for s in lookup(v, "identities", []) : merge(local.defaults.wwnn.reservations, v, {
        identity     = s
        organization = value.organization
        pool_name    = key
      })
    ]]
  ]) : "${i.pool_name}:${i.identity}" => i }


  #____________________________________________________________
  #
  # Intersight WWPN Pool
  # GUI Location: Pools > Create Pool: WWPN
  #____________________________________________________________
  wwpn = {
    for v in lookup(var.pools, "wwpn", {}) : v.name => merge(local.defaults.wwpn, v, {
      assignment_order = lookup(v, "assignment_order", local.defaults.wwpn.assignment_order)
      description      = lookup(v, "description", "")
      id_blocks        = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwpn.id_blocks, e)]
      name             = "${local.name_prefix.wwpn}${v.name}${local.name_suffix.wwpn}"
      organization     = var.pools.organization
      reservations     = lookup(v, "reservations", {})
      tags             = lookup(v, "tags", var.pools.global_settings.tags)
    })
  }
  wwpn_reservations = { for i in flatten([
    for key, value in local.wwpn : [for v in [value.reservations] : [
      for s in lookup(v, "identities", []) : merge(local.defaults.wwpn.reservations, v, {
        identity     = s
        organization = value.organization
        pool_name    = key
      })
    ]]
  ]) : "${i.pool_name}:${i.identity}" => i }
}
