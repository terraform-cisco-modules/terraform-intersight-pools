#____________________________________________________________
#
# Intersight IQN Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_iqnpool_pool" "iqn" {
  for_each         = local.iqn
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} IQN Pool."
  name             = each.value.name
  prefix           = each.value.prefix
  dynamic "iqn_suffix_blocks" {
    for_each = { for v in each.value.iqn_blocks : v.from => v }
    content {
      from   = iqn_suffix_blocks.value.from
      size   = iqn_suffix_blocks.value.size
      suffix = iqn_suffix_blocks.value.suffix
      to     = iqn_suffix_blocks.value.to
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

resource "intersight_iqnpool_reservation" "iqn" {
  for_each        = local.mac_reservations
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  pool {
    moid = intersight_iqnpool_pool.iqn[each.value.pool_name].moid
  }
}
