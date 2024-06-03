#____________________________________________________________
#
# Intersight IP Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_ippool_pool" "map" {
  for_each         = local.ip
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} IP Pool."
  name             = each.value.name
  dynamic "ip_v4_blocks" {
    for_each = { for v in each.value.ipv4_blocks : v.from => v }
    content {
      from = ip_v4_blocks.value.from
      ip_v4_config {
        gateway       = ip_v4_blocks.value.gateway
        netmask       = ip_v4_blocks.value.netmask
        object_type   = "ippool.IpV4Config"
        primary_dns   = ip_v4_blocks.value.primary_dns
        secondary_dns = ip_v4_blocks.value.secondary_dns
      }
      size = ip_v4_blocks.value.size
      to   = ip_v4_blocks.value.to
    }
  }
  dynamic "ip_v4_config" {
    for_each = { for v in each.value.ipv4_config : "default" => v if v.gateway != null }
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
      ip_v6_config {
        gateway       = ip_v6_blocks.value.gateway
        object_type   = "ippool.IpV6Config"
        prefix        = ip_v6_blocks.value.prefix
        primary_dns   = ip_v6_blocks.value.primary_dns
        secondary_dns = ip_v6_blocks.value.secondary_dns
      }
      size = ip_v6_blocks.value.size
      to   = ip_v6_blocks.value.to
    }
  }
  dynamic "ip_v6_config" {
    for_each = { for v in each.value.ipv6_config : "default" => v if v.gateway != null }
    content {
      gateway       = ip_v6_config.value.gateway
      prefix        = ip_v6_config.value.prefix
      primary_dns   = ip_v6_config.value.primary_dns
      secondary_dns = ip_v6_config.value.secondary_dns
    }
  }
  organization { moid = var.orgs[each.value.org] }
  dynamic "tags" {
    for_each = { for v in each.value.tags : v.key => v }
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

resource "intersight_ippool_reservation" "map" {
  depends_on      = [intersight_ippool_pool.map]
  for_each        = { for v in local.reservations : "${v.pool_name}/${v.identity}" => v if v.identity_type == "ip" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  ip_type         = each.value.ip_type
  organization { moid = var.orgs[each.value.org] }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = contains(local.pools.ip.moids, pool.value) ? intersight_ippool_pool.map[pool.value].moid : local.pools_data.ip[pool.value].moid
    }
  }
}

