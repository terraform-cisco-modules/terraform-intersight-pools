#____________________________________________________________
#
# Intersight IQN Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_iqnpool_pool" "map" {
  for_each         = local.iqn
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} IQN Pool."
  name             = each.value.name
  prefix           = each.value.prefix
  dynamic "iqn_suffix_blocks" {
    for_each = { for v in each.value.iqn_blocks : v.from => v }
    content {
      from        = iqn_suffix_blocks.value.from
      object_type = "iqnpool.Block"
      size        = iqn_suffix_blocks.value.size
      suffix      = iqn_suffix_blocks.value.suffix
      to          = iqn_suffix_blocks.value.to
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

resource "intersight_iqnpool_reservation" "map" {
  depends_on      = [intersight_iqnpool_pool.map]
  for_each        = { for v in local.reservations : "${v.pool_name}/${v.identity}" => v if v.identity_type == "iqn" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization { moid = var.orgs[each.value.org] }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = contains(local.pools.iqn.moids, pool.value) ? intersight_iqnpool_pool.map[pool.value].moid : local.pools_data["iqn"][pool.value].moid
    }
  }
}
