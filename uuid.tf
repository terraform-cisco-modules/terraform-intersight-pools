#____________________________________________________________
#
# Intersight UUID Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_uuidpool_pool" "map" {
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
    for_each = { for v in each.value.tags : v.key => v }
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

resource "intersight_uuidpool_reservation" "map" {
  for_each        = local.uuid_reservations
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = intersight_uuidpool_pool.map[each.value.pool_name].moid
    }
  }
}
