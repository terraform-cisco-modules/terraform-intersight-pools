locals {
  defaults = yamldecode(file("${path.module}/defaults.yaml")).pools
  ipv4_cfg = local.lip.ipv4_configuration
  ipv6_cfg = local.lip.ipv6_configuration
  lip      = local.defaults.ip
  name_prefix = [for v in [merge(lookup(local.pools, "name_prefix", {}), local.defaults.name_prefix)] : {
    ip       = v.ip != "" ? v.ip : v.default
    iqn      = v.iqn != "" ? v.iqn : v.default
    mac      = v.mac != "" ? v.mac : v.default
    resource = v.resource != "" ? v.resource : v.default
    uuid     = v.uuid != "" ? v.uuid : v.default
    wwnn     = v.wwnn != "" ? v.wwnn : v.default
    wwpn     = v.wwpn != "" ? v.wwpn : v.default
  }][0]
  name_suffix = [for v in [merge(lookup(local.pools, "name_suffix", {}), local.defaults.name_suffix)] : {
    ip       = v.ip != "" ? v.ip : v.default
    iqn      = v.iqn != "" ? v.iqn : v.default
    mac      = v.mac != "" ? v.mac : v.default
    resource = v.resource != "" ? v.resource : v.default
    uuid     = v.uuid != "" ? v.uuid : v.default
    wwnn     = v.wwnn != "" ? v.wwnn : v.default
    wwpn     = v.wwpn != "" ? v.wwpn : v.default
  }][0]
  orgs  = var.orgs
  pools = var.pools

  #____________________________________________________________
  #
  # Intersight IP Pool
  # GUI Location: Pools > Create Pool: IP
  #____________________________________________________________
  ip = {
    for v in lookup(local.pools, "ip", {}) : v.name => {
      assignment_order = lookup(v, "assignment_order", local.defaults.ip.assignment_order)
      description      = lookup(v, "description", local.lip.description)
      ipv4_blocks = [for e in lookup(v, "ipv4_blocks", []) : {
        from = e.from
        size = lookup(e, "size", null)
        to   = lookup(e, "to", null)
      }]
      ipv4_config = [for e in [lookup(v, "ipv4_configuration", {})] : {
        gateway       = e.gateway
        netmask       = e.netmask
        primary_dns   = lookup(e, "primary_dns", local.ipv4_cfg.primary_dns)
        secondary_dns = lookup(e, "secondary_dns", local.ipv4_cfg.secondary_dns)
      }]
      ipv6_blocks = [for e in lookup(v, "ipv6_blocks", []) : {
        from = e.from
        size = lookup(e, "size", null)
        to   = lookup(e, "to", null)
      }]
      ipv6_config = [for e in flatten([lookup(v, "ipv6_configuration", [])]) : {
        gateway       = e.gateway
        prefix        = e.prefix
        primary_dns   = lookup(e, "primary_dns", local.ipv6_cfg.primary_dns)
        secondary_dns = lookup(e, "secondary_dns", local.ipv6_cfg.secondary_dns)
      }]
      name         = "${local.name_prefix.ip}${v.name}${local.name_suffix.ip}"
      reservations = lookup(v, "reservations", [])
      organization = var.organization
      tags         = lookup(v, "tags", var.tags)
    }
  }
  ip_reservations = { for i in flatten([
    for key, value in local.ip : [
      for v in value.reservations : [
        for e in v.identities : {
          allocation_type = lookup(v, "allocation_type", local.defaults.ip.reservations.allocation_type)
          identity        = e
          ip_type         = lookup(v, "ip_type", local.defaults.ip.reservations.ip_type)
          organization    = value.organization
          pool_name       = key
        }
      ]
    ] if length(value.reservations) > 0
  ]) : "${i.pool}:${i.identity}" => i }

  #____________________________________________________________
  #
  # Intersight IQN Pool
  # GUI Location: Pools > Create Pool: IQN
  #____________________________________________________________
  iqn = {
    for v in lookup(local.pools, "iqn", {}) : v.name => {
      assignment_order = lookup(v, "assignment_order", local.defaults.iqn.assignment_order)
      description      = lookup(v, "description", "")
      iqn_blocks = [for e in lookup(v, "iqn_blocks", []) : {
        from   = e.from
        size   = lookup(e, "size", null)
        suffix = lookup(e, "suffix", local.defaults.iqn.iqn_blocks.suffix)
        to     = lookup(e, "to", null)
      }]
      name         = "${local.name_prefix.iqn}${v.name}${local.name_suffix.iqn}"
      organization = var.organization
      prefix       = lookup(v, "prefix", local.defaults.iqn.prefix)
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  iqn_reservations = { for i in flatten([
    for key, value in local.iqn : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", local.defaults.iqn.reservations.allocation_type)
          identity        = s
          organization    = value.organization
          pool_name       = key
        }
      ]
    ] if length(value.reservations) > 0
  ]) : "${i.pool}:${i.identity}" => i }

  #____________________________________________________________
  #
  # Intersight MAC Pool
  # GUI Location: Pools > Create Pool: MAC
  #____________________________________________________________
  mac = {
    for v in lookup(local.pools, "mac", {}) : v.name => {
      assignment_order = lookup(v, "assignment_order", local.defaults.mac.assignment_order)
      description      = lookup(v, "description", "")
      mac_blocks = [for block in lookup(v, "mac_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.name_prefix.mac}${v.name}${local.name_suffix.mac}"
      organization = var.organization
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  mac_reservations = { for i in flatten([
    for key, value in local.mac : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", local.defaults.mac.reservations.allocation_type)
          identity        = s
          organization    = value.organization
          pool_name       = key
        }
      ]
    ] if length(value.reservations) > 0
  ]) : "${i.pool}:${i.identity}" => i }

  #____________________________________________________________
  #
  # Intersight Resource Pool
  # GUI Location: Pools > Create Pool: Resource
  #____________________________________________________________
  resource = {
    for v in lookup(local.pools, "resource", {}) : v.name => {
      assignment_order   = lookup(v, "assignment_order", local.defaults.resource.assignment_order)
      description        = lookup(v, "description", "")
      name               = "${local.name_prefix.resource}${v.name}${local.name_suffix.resource}"
      organization       = var.organization
      pool_type          = lookup(v, "pool_type", local.defaults.resource.pool_type)
      resource_type      = lookup(v, "resource_type", local.defaults.resource.resource_type)
      serial_number_list = v.serial_number_list
      server_type        = lookup(v, "server_type", local.defaults.resource.server_type)
      tags               = lookup(v, "tags", var.tags)
    }
  }
  serial_number_list = compact(concat([for v in local.resource : v.serial_number_list]))

  #____________________________________________________________
  #
  # Intersight UUID Pool
  # GUI Location: Pools > Create Pool: UUID
  #____________________________________________________________
  uuid = {
    for v in lookup(local.pools, "uuid", {}) : v.name => {
      assignment_order = lookup(v, "assignment_order", local.defaults.uuid.assignment_order)
      description      = lookup(v, "description", "")
      uuid_blocks = [for block in lookup(v, "uuid_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.name_prefix.uuid}${v.name}${local.name_suffix.uuid}"
      organization = var.organization
      prefix       = lookup(v, "prefix", local.defaults.uuid.prefix)
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  uuid_reservations = { for i in flatten([
    for key, value in local.uuid : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", local.defaults.uuid.reservations.allocation_type)
          identity        = s
          organization    = value.organization
          pool_name       = key
        }
      ]
    ] if length(value.reservations) > 0
  ]) : "${i.pool}:${i.identity}" => i }


  #____________________________________________________________
  #
  # Intersight WWNN Pool
  # GUI Location: Pools > Create Pool: WWNN
  #____________________________________________________________
  wwnn = {
    for v in lookup(local.pools, "wwnn", {}) : v.name => {
      assignment_order = lookup(v, "assignment_order", local.defaults.wwnn.assignment_order)
      description      = lookup(v, "description", "")
      id_blocks = [for block in lookup(v, "id_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.name_prefix.wwnn}${v.name}${local.name_suffix.wwnn}"
      organization = var.organization
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  wwnn_reservations = { for i in flatten([
    for key, value in local.wwnn : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", local.defaults.wwnn.reservations.allocation_type)
          identity        = s
          organization    = value.organization
          pool_name       = key
        }
      ]
    ] if length(value.reservations) > 0
  ]) : "${i.pool}:${i.identity}" => i }


  #____________________________________________________________
  #
  # Intersight WWPN Pool
  # GUI Location: Pools > Create Pool: WWPN
  #____________________________________________________________
  wwpn = {
    for v in lookup(local.pools, "wwpn", {}) : v.name => {
      assignment_order = lookup(v, "assignment_order", local.defaults.wwpn.assignment_order)
      description      = lookup(v, "description", "")
      id_blocks = [for block in lookup(v, "id_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.name_prefix.wwpn}${v.name}${local.name_suffix.wwpn}"
      organization = var.organization
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  wwpn_reservations = { for i in flatten([
    for key, value in local.wwpn : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", local.defaults.wwpn.reservations.allocation_type)
          identity        = s
          organization    = value.organization
          pool_name       = key
        }
      ]
    ] if length(value.reservations) > 0
  ]) : "${i.pool}:${i.identity}" => i }
}

