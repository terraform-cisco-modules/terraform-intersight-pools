locals {
  defaults   = lookup(var.model, "defaults", {})
  intersight = lookup(var.model, "intersight", {})
  orgs       = { for k, v in data.intersight_organization_organization.orgs.results : v.name => v.moid }
  pools      = lookup(local.intersight, "pools", {})
}

data "intersight_organization_organization" "orgs" {
}

#____________________________________________________________
#
# Intersight IP Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "ip" {
  source  = "terraform-cisco-modules/pools-ip/intersight"
  version = ">= 1.0.4"

  for_each         = { for ip in lookup(local.pools, "ip", []) : ip.name => ip }
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
    primary_dns   = lookup(config, "primary_dns", local.defaults.intersight.pools.ip.ipv4_config.primary_dns)
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
    primary_dns   = lookup(config, "primary_dns", local.defaults.intersight.pools.ip.ipv6_config.primary_dns)
    secondary_dns = lookup(config, "secondary_dns", "::")
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.ip.name_suffix}"
  organization = local.orgs[lookup(each.value, "organization", local.defaults.intersight.organization)]
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}


#____________________________________________________________
#
# Intersight IQN Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "iqn" {
  source  = "terraform-cisco-modules/pools-iqn/intersight"
  version = ">= 1.0.4"

  for_each         = { for ip in lookup(local.pools, "iqn", []) : ip.name => ip }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  iqn_blocks = [for block in lookup(each.value, "iqn_blocks", []) : {
    from   = block.from
    size   = lookup(block, "size", null)
    suffix = lookup(block, "suffix", local.defaults.intersight.pools.iqn.iqn_blocks.suffix)
    to     = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.iqn.name_suffix}"
  organization = local.orgs[lookup(each.value, "organization", local.defaults.intersight.organization)]
  prefix       = lookup(each.value, "prefix", local.defaults.intersight.pools.iqn.prefix)
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}


#____________________________________________________________
#
# Intersight MAC Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "mac" {
  source  = "terraform-cisco-modules/pools-mac/intersight"
  version = ">= 1.0.4"

  for_each         = { for mac in lookup(local.pools, "mac", []) : mac.name => mac }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  mac_blocks = [for block in lookup(each.value, "mac_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.mac.name_suffix}"
  organization = local.orgs[lookup(each.value, "organization", local.defaults.intersight.organization)]
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}


#____________________________________________________________
#
# Intersight Resource Pool Resource
# GUI Location: Pools > Create Pool > Resource Pool
#____________________________________________________________

module "resource" {
  source  = "terraform-cisco-modules/pools-resource/intersight"
  version = ">= 1.0.4"

  for_each           = { for rp in lookup(local.pools, "resource", []) : rp.name => rp }
  assignment_order   = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description        = lookup(each.value, "description", "")
  name               = "${each.value.name}${local.defaults.intersight.pools.resource.name_suffix}"
  organization       = local.orgs[lookup(each.value, "organization", local.defaults.intersight.organization)]
  pool_type          = lookup(each.value, "pool_type", local.defaults.intersight.pools.resource.pool_type)
  resource_type      = lookup(each.value, "resource_type", local.defaults.intersight.pools.resource.resource_type)
  serial_number_list = each.value.serial_number_list
  server_type        = lookup(each.value, "server_type", local.defaults.intersight.pools.resource.server_type)
  tags               = lookup(each.value, "tags", local.defaults.intersight.tags)
}

#____________________________________________________________
#
# Intersight UUID Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "uuid" {
  source  = "terraform-cisco-modules/pools-uuid/intersight"
  version = ">= 1.0.4"

  for_each         = { for uuid in lookup(local.pools, "uuid", []) : uuid.name => uuid }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  uuid_blocks = [for block in lookup(each.value, "uuid_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.uuid.name_suffix}"
  organization = local.orgs[lookup(each.value, "organization", local.defaults.intersight.organization)]
  prefix       = lookup(each.value, "prefix", local.defaults.intersight.pools.uuid.prefix)
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}

#____________________________________________________________
#
# Intersight Fiber-Channel Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

module "wwnn" {
  source  = "terraform-cisco-modules/pools-fc/intersight"
  version = ">= 1.0.4"

  for_each         = { for fc in lookup(local.pools, "wwnn", []) : fc.name => fc }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  id_blocks = [for block in lookup(each.value, "id_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.wwnn.name_suffix}"
  organization = local.orgs[lookup(each.value, "organization", local.defaults.intersight.organization)]
  pool_purpose = lookup(each.value, "pool_purpose", "WWNN")
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}

module "wwpn" {
  source           = "terraform-cisco-modules/pools-fc/intersight"
  version          = ">= 1.0.4"
  for_each         = { for fc in lookup(local.pools, "wwpn", []) : fc.name => fc }
  assignment_order = lookup(each.value, "assignment_order", local.defaults.intersight.pools.assignment_order)
  description      = lookup(each.value, "description", "")
  id_blocks = [for block in lookup(each.value, "id_blocks", []) : {
    from = block.from
    size = lookup(block, "size", null)
    to   = lookup(block, "to", null)
  }]
  name         = "${each.value.name}${local.defaults.intersight.pools.wwnn.name_suffix}"
  organization = local.orgs[lookup(each.value, "organization", local.defaults.intersight.organization)]
  pool_purpose = lookup(each.value, "pool_purpose", "WWPN")
  tags         = lookup(each.value, "tags", local.defaults.intersight.tags)
}
