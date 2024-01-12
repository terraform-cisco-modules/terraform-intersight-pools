#____________________________________________________________
#
# Intersight MAC Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_macpool_pool" "map" {
  for_each         = local.mac
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} MAC Pool."
  name             = each.value.name
  dynamic "mac_blocks" {
    for_each = { for v in each.value.mac_blocks : v.from => v }
    content {
      object_type = "macpool.Block"
      from        = mac_blocks.value.from
      size        = mac_blocks.value.size
      to          = mac_blocks.value.to
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

resource "intersight_macpool_pool" "data" {
  depends_on = [intersight_macpool_pool.map]
  for_each   = { for v in local.reservation_mac_pools : v => v if lookup(local.mac, v, "#NOEXIST") == "#NOEXIST" }
  name       = element(split("/", each.value), 1)
  organization {
    moid = local.orgs[element(split("/", each.value), 0)]
  }
  lifecycle {
    ignore_changes = [
      account_moid, additional_properties, ancestors, assigned, assignment_order, block_heads, create_time, description, domain_group_moid,
      mac_blocks, mod_time, owners, parent, permission_resources, reservations, reserved, shared_scope, size, tags, version_context
    ]
    prevent_destroy = true
  }
}

resource "intersight_macpool_reservation" "map" {
  depends_on      = [intersight_macpool_pool.data]
  for_each        = { for v in local.reservations : "${v.combined}/${v.identity}" => v if v.identity_type == "mac" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = lookup(local.mac, each.value.combined, "#NOEXIST") != "#NOEXIST" ? intersight_macpool_pool.map[each.value.combined
      ].moid : intersight_macpool_pool.data[each.value.combined].moid
    }
  }
}
