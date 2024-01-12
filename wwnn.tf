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

resource "intersight_fcpool_pool" "wwnn_data" {
  depends_on = [intersight_fcpool_pool.wwnn]
  for_each   = { for v in local.reservation_wwnn_pools : v => v if lookup(local.wwnn, v, "#NOEXIST") == "#NOEXIST" }
  name       = element(split("/", each.value), 1)
  organization {
    moid = local.orgs[element(split("/", each.value), 0)]
  }
  pool_purpose = "WWNN"
  lifecycle {
    ignore_changes = [
      account_moid, additional_properties, ancestors, assigned, assignment_order, block_heads, create_time, description, domain_group_moid,
      id_blocks, mod_time, owners, parent, permission_resources, reservations, reserved, shared_scope, size, tags, version_context
    ]
    prevent_destroy = true
  }
}

resource "intersight_fcpool_reservation" "wwnn" {
  depends_on      = [intersight_fcpool_pool.wwnn_data]
  for_each        = { for v in local.reservations : "${v.combined}/${v.identity}" => v if v.identity_type == "wwnn" }
  allocation_type = each.value.allocation_type # dynamic|static
  identity        = each.value.identity
  id_purpose      = "WWNN"
  organization {
    moid        = local.orgs[each.value.organization]
    object_type = "organization.Organization"
  }
  dynamic "pool" {
    for_each = { for v in [each.value.pool_name] : v => v if each.value.allocation_type == "dynamic" }
    content {
      moid = lookup(local.wwnn, each.value.combined, "#NOEXIST") != "#NOEXIST" ? intersight_fcpool_pool.wwnn[each.value.combined
      ].moid : intersight_fcpool_pool.wwnn_data[each.value.combined].moid
    }
  }
}
