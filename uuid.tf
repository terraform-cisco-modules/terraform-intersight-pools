#____________________________________________________________
#
# Intersight UUID Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_uuidpool_pool" "uuid" {
  for_each         = local.uuid
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} UUID Pool."
  name             = each.value.name
  prefix           = each.value.prefix
  dynamic "uuid_suffix_blocks" {
    for_each = { for v in each.value.uuid_blocks : v.from => v }
    content {
      object_type = "uuidpool.UuidBlock"
      from        = uuid_suffix_blocks.value.from
      size        = uuid_suffix_blocks.value.size
      to          = uuid_suffix_blocks.value.to
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

resource "intersight_uuidpool_reservation" "uuid" {
  for_each        = local.mac_reservations
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  pool {
    moid = intersight_uuidpool_pool.uuid[each.value.pool_name].moid
  }
}
