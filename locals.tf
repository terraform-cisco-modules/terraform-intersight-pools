locals {
  defaults   = lookup(var.model, "defaults", {})
  intersight = lookup(var.model, "intersight", {})
  orgs       = { for k, v in data.intersight_organization_organization.orgs.results : v.name => v.moid }
  pools      = lookup(local.intersight, "pools", {})

  #____________________________________________________________
  #
  # Intersight IP Pool
  # GUI Location: Pools > Create Pool: IP
  #____________________________________________________________
  ip = {
    for v in lookup(local.pools, "ip", {}) : v.name => {
      assignment_order = lookup(v, "assignment_order", local.defaults.intersight.pools.assignment_order)
      description      = lookup(v, "description", "")
      ipv4_blocks = [for block in lookup(v, "ipv4_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      ipv4_config = [for config in lookup(v, "ipv4_config", []) : {
        gateway       = config.gateway
        netmask       = config.netmask
        primary_dns   = lookup(config, "primary_dns", local.defaults.intersight.pools.ip.ipv4_config.primary_dns)
        secondary_dns = lookup(config, "secondary_dns", null)
      }]
      ipv6_blocks = [for block in lookup(v, "ipv6_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      ipv6_config = [for config in lookup(v, "ipv6_config", []) : {
        gateway       = config.gateway
        prefix        = config.prefix
        primary_dns   = lookup(config, "primary_dns", local.defaults.intersight.pools.ip.ipv6_config.primary_dns)
        secondary_dns = lookup(config, "secondary_dns", "::")
      }]
      name         = "${local.defaults.intersight.pools.name_prefix}${v.name}${local.defaults.intersight.pools.ip.name_suffix}"
      reservations = lookup(v, "reservations", [])
      organization = lookup(v, "organization", var.organization)
      tags         = lookup(v, "tags", var.tags)
    }
  }
  ip_reservations = { for i in flatten([
    for value in local.ip : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", "static")
          identity        = s
          ip_type         = lookup(v, "ip_type", "IPv4")
          organization    = value.organization
          pool_name       = value.name
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
      assignment_order = lookup(v, "assignment_order", local.defaults.intersight.pools.assignment_order)
      description      = lookup(v, "description", "")
      iqn_blocks = [for block in lookup(v, "iqn_blocks", []) : {
        from   = block.from
        size   = lookup(block, "size", null)
        suffix = lookup(block, "suffix", local.defaults.intersight.pools.iqn.iqn_blocks.suffix)
        to     = lookup(block, "to", null)
      }]
      name         = "${local.defaults.intersight.pools.name_prefix}${v.name}${local.defaults.intersight.pools.iqn.name_suffix}"
      organization = lookup(v, "organization", var.organization)
      prefix       = lookup(v, "prefix", local.defaults.intersight.pools.iqn.prefix)
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  iqn_reservations = { for i in flatten([
    for value in local.iqn : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", "static")
          identity        = s
          organization    = value.organization
          pool_name       = value.name
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
      assignment_order = lookup(v, "assignment_order", local.defaults.intersight.pools.assignment_order)
      description      = lookup(v, "description", "")
      mac_blocks = [for block in lookup(v, "mac_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.defaults.intersight.pools.name_prefix}${v.name}${local.defaults.intersight.pools.mac.name_suffix}"
      organization = lookup(v, "organization", var.organization)
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  mac_reservations = { for i in flatten([
    for value in local.mac : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", "static")
          identity        = s
          organization    = value.organization
          pool_name       = value.name
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
      assignment_order   = lookup(v, "assignment_order", local.defaults.intersight.pools.assignment_order)
      description        = lookup(v, "description", "")
      name               = "${local.defaults.intersight.pools.name_prefix}${v.name}${local.defaults.intersight.pools.resource.name_suffix}"
      organization       = lookup(v, "organization", var.organization)
      pool_type          = lookup(v, "pool_type", local.defaults.intersight.pools.resource.pool_type)
      resource_type      = lookup(v, "resource_type", local.defaults.intersight.pools.resource.resource_type)
      serial_number_list = v.serial_number_list
      server_type        = lookup(v, "server_type", local.defaults.intersight.pools.resource.server_type)
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
      assignment_order = lookup(v, "assignment_order", local.defaults.intersight.pools.assignment_order)
      description      = lookup(v, "description", "")
      uuid_blocks = [for block in lookup(v, "uuid_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.defaults.intersight.pools.name_prefix}${v.name}${local.defaults.intersight.pools.uuid.name_suffix}"
      organization = lookup(v, "organization", var.organization)
      prefix       = lookup(v, "prefix", local.defaults.intersight.pools.uuid.prefix)
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  uuid_reservations = { for i in flatten([
    for value in local.uuid : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", "static")
          identity        = s
          organization    = value.organization
          pool_name       = value.name
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
      assignment_order = lookup(v, "assignment_order", local.defaults.intersight.pools.assignment_order)
      description      = lookup(v, "description", "")
      id_blocks = [for block in lookup(v, "id_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.defaults.intersight.pools.name_prefix}${v.name}${local.defaults.intersight.pools.wwnn.name_suffix}"
      organization = lookup(v, "organization", var.organization)
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  wwnn_reservations = { for i in flatten([
    for value in local.wwnn : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", "static")
          identity        = s
          organization    = value.organization
          pool_name       = value.name
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
      assignment_order = lookup(v, "assignment_order", local.defaults.intersight.pools.assignment_order)
      description      = lookup(v, "description", "")
      id_blocks = [for block in lookup(v, "id_blocks", []) : {
        from = block.from
        size = lookup(block, "size", null)
        to   = lookup(block, "to", null)
      }]
      name         = "${local.defaults.intersight.pools.name_prefix}${v.name}${local.defaults.intersight.pools.wwnn.name_suffix}"
      organization = lookup(v, "organization", var.organization)
      reservations = lookup(v, "reservations", [])
      tags         = lookup(v, "tags", var.tags)
    }
  }
  wwpn_reservations = { for i in flatten([
    for value in local.wwpn : [
      for v in value.reservations : [
        for s in v.identities : {
          allocation_type = lookup(v, "allocation_type", "static")
          identity        = s
          organization    = value.organization
          pool_name       = value.name
        }
      ]
    ] if length(value.reservations) > 0
  ]) : "${i.pool}:${i.identity}" => i }
}

