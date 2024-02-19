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
    moid        = var.orgs[each.value.organization]
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

resource "intersight_macpool_reservation" "map" {
  depends_on      = [intersight_macpool_pool.map]
  for_each        = { for v in local.reservations : "${v.combined}/${v.identity}" => v if v.identity_type == "mac" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization {
    moid        = var.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "pool" {
    for_each = { for v in [each.value.combined] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = contains(local.pools.mac.moids, each.value.combined) ? intersight_macpool_pool.map[each.value.combined
        ].moid : [for i in data.intersight_search_search_item.pools["mac"
          ].results : i.moid if jsondecode(i.additional_properties).Name == each.value.pool && jsondecode(i.additional_properties
      ).Organization.Moid == var.orgs[each.value.org]][0]
    }
  }
}
