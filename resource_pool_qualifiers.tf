#____________________________________________________________
#
# Intersight IP Pool Resource
# GUI Location: Pools > Create Pool
#____________________________________________________________

resource "intersight_resourcepool_qualification_policy" "map" {
  for_each    = local.server_pool_qualification
  description = each.value.description != "" ? each.value.description : "${each.value.name} Server Pool Qualification."
  name        = each.value.name
  organization { moid = var.orgs[each.value.org] }
  qualifiers = [for e in local.spqt : lookup(each.value, e, {}) if length(lookup(each.value, e, {})) > 0]
  dynamic "tags" {
    for_each = { for v in each.value.tags : v.key => v }
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
