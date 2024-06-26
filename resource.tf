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
  for_each         = local.resource
  assignment_order = each.value.assignment_order
  description      = each.value.description != "" ? each.value.description : "${each.value.name} Resource Pool."
  name             = each.value.name
  pool_type        = each.value.pool_type
  resource_pool_parameters = [
    {
      additional_properties = jsonencode(
        { ManagementMode = data.intersight_compute_physical_summary.servers[each.value.serial_number_list[0]].results[0].management_mode }
      )
      class_id    = "resourcepool.ServerPoolParameters"
      object_type = "resourcepool.ServerPoolParameters"
    }
  ]
  resource_type = each.value.resource_type
  selectors = [
    {
      additional_properties = ""
      class_id              = "resource.Selector"
      object_type           = "resource.Selector"
      selector = "/api/v1/compute/${element(split(".", data.intersight_compute_physical_summary.servers[each.value.serial_number_list[0]
        ].results[0].source_object_type), 1)}s?$filter=(Serial in (${format("'%s'", join("','", [
        for s in each.value.serial_number_list : s
      ]))})) and (ManagementMode eq '${data.intersight_compute_physical_summary.servers[each.value.serial_number_list[0]].results[0].management_mode}')"
    }
  ]
  organization { moid = var.orgs[each.value.org] }
  dynamic "tags" {
    for_each = { for v in each.value.tags : v.key => v }
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}
