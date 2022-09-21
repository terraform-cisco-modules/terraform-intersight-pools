locals {
  defaults   = lookup(var.model, "defaults", {})
  modules    = lookup(var.model, "modules", {})
  intersight = lookup(var.model, "intersight", {})
  pools      = lookup(local.intersight, "pools", {})
}

#____________________________________________________________
#
# Intersight IP Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "intersight_ip_pools" {
  source           = "terraform-cisco-modules/pools-ip/intersight"
  version          = ">= 1.0.1"
  for_each         = { for ip in lookup(local.pools, "ip_pools", []) : ip.name => ip if lookup(local.modules, "ip_pools", true) }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  ipv4_blocks = [for block in lookup(each.value, "ipv4_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  ipv4_config = [for config in lookup(each.value, "ipv4_config", []) : {
    gateway       = config.gateway
    netmask       = config.netmask
    primary_dns   = lookup(config, "primary_dns", local.defaults.intersight.pools.ip_pools.ipv4_config.primary_dns)
    secondary_dns = lookup(config, "secondary_dns", null)
  }]
  ipv6_blocks = [for block in lookup(each.value, "ipv6_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  ipv6_config = [for config in lookup(each.value, "ipv6_config", []) : {
    gateway       = config.gateway
    prefix        = config.prefix
    primary_dns   = lookup(config, "primary_dns", local.defaults.intersight.pools.ip_pools.ipv6_config.primary_dns)
    secondary_dns = lookup(config, "secondary_dns", "::")
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.ip_pools.name_suffix}"
  organization = lookup(each.value, "organization", local.defaults.intersight.organization)
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}


#____________________________________________________________
#
# Intersight IQN Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "intersight_iqn_pools" {
  source           = "terraform-cisco-modules/pools-iqn/intersight"
  version          = ">= 1.0.1"
  for_each         = { for ip in lookup(local.pools, "iqn_pools", []) : ip.name => ip if lookup(local.modules, "iqn_pools", true) }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  iqn_suffix_blocks = [for block in lookup(each.value, "iqn_suffix_blocks", []) : {
    from   = block.from
    size   = lookup(block, "size", null)
    suffix = lookup(block, "suffix", local.defaults.intersight.pools.iqn_pools.iqn_suffix_blocks.suffix)
    to     = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.iqn_pools.name_suffix}"
  organization = lookup(each.value, "organization", local.defaults.intersight.organization)
  prefix       = lookup(each.value, "prefix", local.defaults.intersight.pools.iqn_pools.prefix)
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}


#____________________________________________________________
#
# Intersight MAC Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "intersight_mac_pools" {
  source           = "terraform-cisco-modules/pools-mac/intersight"
  version          = ">= 1.0.1"
  for_each         = { for mac in lookup(local.pools, "mac_pools", []) : mac.name => mac if lookup(local.modules, "mac_pools", true) }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  mac_blocks = [for block in lookup(each.value, "mac_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.mac_pools.name_suffix}"
  organization = lookup(each.value, "organization", local.defaults.intersight.organization)
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}


#____________________________________________________________
#
# Intersight Resource Pool Resource
# GUI Location: Pools > Create Pool > Resource Pool
#____________________________________________________________

module "intersight_resource_pools" {
  source             = "terraform-cisco-modules/pools-resource/intersight"
  version            = ">= 1.0.1"
  for_each           = { for rp in lookup(local.pools, "resource_pools", []) : rp.name => rp if lookup(local.modules, "resource_pools", true) }
  assignment_order   = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description        = lookup(each.value, "description", "")
  name               = "${each.value.name}${local.defaults.intersight.pools.resource_pools.name_suffix}"
  organization       = lookup(each.value, "organization", local.defaults.intersight.organization)
  pool_type          = lookup(each.value, "pool_type", local.defaults.intersight.pools.resource_pools.pool_type)
  resource_type      = lookup(each.value, "resource_type", local.defaults.intersight.pools.resource_pools.resource_type)
  serial_number_list = each.value.serial_number_list
  server_type        = lookup(each.value, "server_type", local.defaults.intersight.pools.resource_pools.server_type)
  tags               = lookup(each.value, "tags", local.defaults.intersight.tags)
}

#____________________________________________________________
#
# Intersight UUID Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "intersight_uuid_pools" {
  source           = "terraform-cisco-modules/pools-uuid/intersight"
  version          = ">= 1.0.1"
  for_each         = { for uuid in lookup(local.pools, "uuid_pools", []) : uuid.name => uuid if lookup(local.modules, "uuid_pools", true) }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  uuid_blocks = [for block in lookup(each.value, "uuid_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.uuid_pools.name_suffix}"
  organization = lookup(each.value, "organization", local.defaults.intersight.organization)
  prefix       = lookup(each.value, "prefix", local.defaults.intersight.pools.uuid_pools.prefix)
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}

#____________________________________________________________
#
# Intersight Fiber-Channel Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "intersight_wwnn_pools" {
  source           = "terraform-cisco-modules/pools-fc/intersight"
  version          = ">= 1.0.1"
  for_each         = { for fc in lookup(local.pools, "wwnn_pools", []) : fc.name => fc if lookup(local.modules, "wwnn_pools", true) }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  id_blocks = [for block in lookup(each.value, "id_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.wwnn_pools.name_suffix}"
  organization = lookup(each.value, "organization", local.defaults.intersight.organization)
  pool_purpose = lookup(each.value, "pool_purpose", "WWNN")
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}

module "intersight_wwpn_pools" {
  source           = "terraform-cisco-modules/pools-fc/intersight"
  version          = ">= 1.0.1"
  for_each         = { for fc in lookup(local.pools, "wwpn_pools", []) : fc.name => fc if lookup(local.modules, "wwpn_pools", true) }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  id_blocks = [for block in lookup(each.value, "id_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.wwnn_pools.name_suffix}"
  organization = lookup(each.value, "organization", local.defaults.intersight.organization)
  pool_purpose = lookup(each.value, "pool_purpose", "WWPN")
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}

