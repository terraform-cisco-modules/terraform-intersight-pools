#____________________________________________________________
#
# Server Moid Data Source
# GUI Location:
#   Operate > Servers > Copy the Serial from the Column.
#____________________________________________________________

data "intersight_compute_physical_summary" "servers" {
  for_each = { for v in local.serial_number_list : v => v }
  serial   = each.value
}

#____________________________________________________________
#
# Intersight Resource Pool Resource
# GUI Location: Pools > Create Pool > Resource Pool
#____________________________________________________________

resource "intersight_resourcepool_pool" "map" {
  depends_on       = [intersight_resourcepool_qualification_policy.map]
  for_each         = local.resource
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} Resource Pool."
  name             = each.value.name
  pool_type = length(each.value.server_pool_qualification_policies) > 0 && length(each.value.static_resource_selection
  ) > 0 ? "Hybrid" : length(each.value.server_pool_qualification_policies) > 0 ? "Dynamic" : "Static"
  resource_pool_parameters = [
    {
      additional_properties = jsonencode(
        { ManagementMode = each.value.target_platform == "Standalone" ? "IntersightStandalone" : "Intersight" }
      )
      class_id    = "resourcepool.ServerPoolParameters"
      object_type = "resourcepool.ServerPoolParameters"
    }
  ]
  resource_type = each.value.resource_type
  organization { moid = var.orgs[each.value.org] }
  dynamic "qualification_policies" {
    for_each = { for v in each.value.server_pool_qualification_policies : v => v if element(split("/", v), 1) != "UNUSED" }
    content {
      moid = contains(keys(local.server_pool_qualification), qualification_policies.value
        ) == true ? intersight_resourcepool_qualification_policy.map[qualification_policies.value
      ].moid : local.policies_data["server_pool_qualification"][qualification_policies.value].moid
    }
  }
  dynamic "selectors" {
    for_each = { for e in ["map"] : e => each.value.static_resource_selection if length(each.value.static_resource_selection) > 0 }
    content {
      additional_properties = ""
      class_id              = "resource.Selector"
      object_type           = "resource.Selector"
      selector = "/api/v1/compute/${element(split(".", data.intersight_compute_physical_summary.servers[each.value.static_resource_selection[0]
        ].results[0].source_object_type), 1)}s?$filter=(Serial in (${format("'%s'", join("','", [
        for s in each.value.static_resource_selection : s
      ]))})) and (ManagementMode eq '${data.intersight_compute_physical_summary.servers[each.value.static_resource_selection[0]].results[0].management_mode}')"
    }
  }
  dynamic "tags" {
    for_each = { for v in each.value.tags : v.key => v }
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
