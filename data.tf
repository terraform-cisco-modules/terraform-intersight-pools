#__________________________________________________________________
#
# Data Objects - Pools and Policies
#__________________________________________________________________
data "intersight_search_search_item" "policies" {
  for_each = { for v in local.policy_types : v => v if length(compact(local.data_policies[v])) > 0 }
  additional_properties = jsonencode(
    { "ObjectType" = "${local.policies[each.key].object}' and Name in ('${trim(join("', '", local.data_policies[each.key]), ", '")}') and ClassId eq '${local.policies[each.key].object}" }
  )
}
data "intersight_search_search_item" "pools" {
  for_each = { for v in local.pool_types : v => v if length(local.data_pools[v]) > 0 }
  additional_properties = length(regexall("wwnn|wwpn", each.key)
    ) > 0 ? jsonencode({ "ObjectType" = "${local.pools[each.key].object}' and Name in ('${trim(join("', '", local.data_pools[each.key]), ", '")}') and PoolPurpose eq '${upper(each.key)}" }
  ) : jsonencode({ "ObjectType" = "${local.pools[each.key].object}' and Name in ('${trim(join("', '", local.data_pools[each.key]), ", '")}') and ClassId eq '${local.pools[each.key].object}" })
}
