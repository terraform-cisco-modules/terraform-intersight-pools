#____________________________________________________________
#
# Intersight Fiber-Channel Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_fcpool_pool" "wwpn" {
  for_each         = local.wwpn
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} WWPN Pool."
  name             = each.value.name
  pool_purpose     = "WWPN"
  dynamic "id_blocks" {
    for_each = { for v in each.value.id_blocks : v.from => v }
    content {
      object_type = "fcpool.Block"
      from        = id_blocks.value.from
      size        = id_blocks.value.size
      to          = id_blocks.value.to
    }
  }
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "tags" {
    for_each = each.value.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

resource "intersight_fcpool_reservation" "wwpn" {
  for_each        = local.wwpn_reservations
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  id_purpose      = "WWPN"
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  pool {
    moid = intersight_fcpool_pool.wwpn[each.value.pool_name].moid
  }
}
