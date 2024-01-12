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

resource "intersight_ippool_pool" "data" {
  depends_on = [intersight_ippool_pool.map]
  for_each   = { for v in local.reservation_ip_pools : v => v if lookup(local.ip, v, "#NOEXIST") == "#NOEXIST" }
  name       = element(split("/", each.value), 1)
  organization {
    moid = local.orgs[element(split("/", each.value), 0)]
  }
  lifecycle {
    ignore_changes = [
      account_moid, additional_properties, ancestors, assigned, assignment_order, create_time, description, domain_group_moid,
      ip_v4_blocks, ip_v4_config, ip_v6_blocks, ip_v6_config, mod_time, owners, parent, permission_resources, reservations, reserved,
      shadow_pools, shared_scope, size, tags, v4_assigned, v4_size, v6_assigned, v6_size, version_context
    ]
    prevent_destroy = true
  }
}

resource "intersight_ippool_reservation" "map" {
  depends_on      = [intersight_ippool_pool.data]
  for_each        = { for v in local.reservations : "${v.combined}/${v.identity}" => v if v.identity_type == "ip" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  ip_type         = each.value.ip_type
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = lookup(local.ip, each.value.combined, "#NOEXIST") != "#NOEXIST" ? intersight_ippool_pool.map[each.value.combined
      ].moid : intersight_ippool_pool.data[each.value.combined].moid
    }
  }
}

