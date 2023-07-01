#____________________________________________________________
#
# Intersight IP Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_ippool_pool" "ip" {
  for_each         = local.ip
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} IP Pool."
  name             = each.value.name
  dynamic "ip_v4_blocks" {
    for_each = { for v in each.value.ipv4_blocks : v.from => v }
    content {
      from = ip_v4_blocks.value.from
      size = ip_v4_blocks.value.size
      to   = ip_v4_blocks.value.to
    }
  }
  dynamic "ip_v4_config" {
    for_each = each.value.ipv4_config
    content {
      gateway       = ip_v4_config.value.gateway
      netmask       = ip_v4_config.value.netmask
      primary_dns   = ip_v4_config.value.primary_dns
      secondary_dns = ip_v4_config.value.secondary_dns
    }
  }
  dynamic "ip_v6_blocks" {
    for_each = { for v in each.value.ipv6_blocks : v.from => v }
    content {
      from = ip_v6_blocks.value.from
      size = ip_v6_blocks.value.size
      to   = ip_v6_blocks.value.to
    }
  }
  dynamic "ip_v6_config" {
    for_each = each.value.ipv6_config
    content {
      gateway       = ip_v6_config.value.gateway
      prefix        = ip_v6_config.value.prefix
      primary_dns   = ip_v6_config.value.primary_dns
      secondary_dns = ip_v6_config.value.secondary_dns
    }
  }
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = { for v in each.value.tags : v.key => v }
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

resource "intersight_ippool_reservation" "ip" {
  for_each        = local.ip_reservations
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  ip_type         = each.value.ip_type
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  pool {
    moid = intersight_ippool_pool.ip[each.value.pool_name].moid
  }
}
