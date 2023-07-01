#____________________________________________________________
#
# Intersight MAC Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_macpool_pool" "mac" {
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

resource "intersight_macpool_reservation" "mac" {
  for_each        = local.mac_reservations
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  pool {
    moid = intersight_macpool_pool.mac[each.value.pool_name].moid
  }
}
