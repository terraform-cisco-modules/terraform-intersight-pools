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
      object_type = "uuidpool.uuidBlock"
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

resource "intersight_uuidpool_pool" "data" {
  depends_on = [intersight_uuidpool_pool.map]
  for_each   = { for v in local.reservation_uuid_pools : v => v if lookup(local.uuid, v, "#NOEXIST") == "#NOEXIST" }
  name       = element(split("/", each.value), 1)
  organization {
    moid = local.orgs[element(split("/", each.value), 0)]
  }
  lifecycle {
    ignore_changes = [
      account_moid, additional_properties, ancestors, assigned, assignment_order, block_heads, create_time, description, domain_group_moid,
      mod_time, owners, parent, permission_resources, prefix, reservations, reserved, shared_scope, size, tags, uuid_suffix_blocks, version_context
    ]
    prevent_destroy = true
  }
}

resource "intersight_uuidpool_reservation" "map" {
  depends_on      = [intersight_uuidpool_pool.data]
  for_each        = { for v in local.reservations : "${v.combined}/${v.identity}" => v if v.identity_type == "uuid" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = lookup(local.uuid, each.value.combined, "#NOEXIST") != "#NOEXIST" ? intersight_uuidpool_pool.map[each.value.combined
      ].moid : intersight_uuidpool_pool.data[each.value.combined].moid
    }
  }
}
