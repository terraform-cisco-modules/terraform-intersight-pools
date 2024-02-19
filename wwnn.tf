#____________________________________________________________
#
# Intersight Fiber-Channel Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_fcpool_pool" "wwnn" {
  for_each         = local.wwnn
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} WWNN Pool."
  name             = each.value.name
  pool_purpose     = "WWNN"
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

resource "intersight_fcpool_reservation" "wwnn" {
  depends_on      = [intersight_fcpool_pool.wwnn]
  for_each        = { for v in local.reservations : "${v.combined}/${v.identity}" => v if v.identity_type == "wwnn" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  id_purpose      = "WWNN"
  organization {
    moid        = var.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "pool" {
    for_each = { for v in [each.value.combined] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = contains(local.pools.wwnn.moids, each.value.combined) ? intersight_fcpool_pool.wwnn[each.value.combined
        ].moid : [for i in data.intersight_search_search_item.pools["wwnn"
          ].results : i.moid if jsondecode(i.additional_properties).Name == each.value.pool && jsondecode(i.additional_properties
      ).Organization.Moid == var.orgs[each.value.org]][0]
    }
  }
}
