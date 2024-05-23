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
  organization { moid = var.orgs[each.value.org] }
  dynamic "tags" {
    for_each = { for v in each.value.tags : v.key => v }
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

resource "intersight_fcpool_reservation" "wwpn" {
  depends_on      = [intersight_fcpool_pool.wwpn]
  for_each        = { for v in local.reservations : "${v.pool_name}/${v.identity}" => v if v.identity_type == "wwpn" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  id_purpose      = "WWPN"
  organization { moid = var.orgs[each.value.org] }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = contains(local.pools.wwpn.moids, pool.value) ? intersight_fcpool_pool.wwpn[pool.value].moid : local.pools_data["wwpn"][pool.value].moid
    }
  }
}
