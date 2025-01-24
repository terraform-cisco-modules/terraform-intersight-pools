locals {
  #____________________________________________________________
  #
  # local defaults and name suffix/prefix
  #____________________________________________________________
  defaults  = yamldecode(file("${path.module}/defaults.yaml")).pools
  model     = { for org in local.org_keys : org => lookup(var.model[org], "pools", {}) }
  pool_type = ["ip", "iqn", "mac", "resource", "uuid", "wwnn", "wwpn"]
  name_prefix = { for org in local.org_keys : org => {
    for e in local.pool_type : e => lookup(lookup(local.model[org], "name_prefix", {}
    ), e, lookup(lookup(local.model[org], "name_prefix", local.defaults.name_prefix), "default", ""))
  } }
  name_suffix = { for org in local.org_keys : org => {
    for e in local.pool_type : e => lookup(lookup(local.model[org], "name_suffix", {}
    ), e, lookup(lookup(local.model[org], "name_suffix", local.defaults.name_suffix), "default", ""))
  } }
  npfx = { for org in keys(var.orgs) : org => {
    for e in local.pool_type : e => lookup(lookup(lookup(local.model, org, {}), "name_prefix", {}
    ), e, lookup(lookup(lookup(local.model, org, {}), "name_prefix", local.defaults.name_prefix), "default", ""))
  } }
  nsfx = { for org in keys(var.orgs) : org => {
    for e in local.pool_type : e => lookup(lookup(lookup(local.model, org, {}), "name_suffix", {}
    ), e, lookup(lookup(lookup(local.model, org, {}), "name_suffix", local.defaults.name_suffix), "default", ""))
  } }
  org_keys        = sort(keys(var.model))
  org_names       = merge({ for k, v in var.orgs : v => k }, jsondecode("{\"5ddfd9ff6972652d31ee6582\":\"x_cisco_intersight_internal\"}"))
  policy_defaults = yamldecode(file("${path.module}/defaults.yaml")).policies
  policies_model  = { for org in local.org_keys : org => lookup(var.model[org], "policies", {}) }
  policy_names    = ["server_pool_qualification"]
  ppfx = { for org in keys(var.orgs) : org => {
    for e in local.policy_names : e => lookup(lookup(lookup(lookup(var.model, org, {}), "policies", {}), "name_prefix", {}
    ), e, lookup(lookup(lookup(lookup(var.model, org, {}), "policies", {}), "name_prefix", local.policy_defaults.name_prefix), "default", ""))
  } }
  psfx = { for org in keys(var.orgs) : org => {
    for e in local.policy_names : e => lookup(lookup(lookup(lookup(var.model, org, {}), "policies", {}), "name_suffix", {}
    ), e, lookup(lookup(lookup(lookup(var.model, org, {}), "policies", {}), "name_suffix", local.policy_defaults.name_suffix), "default", ""))
  } }

  #____________________________________________________________
  #
  # Intersight IP Pool
  # GUI Location: Pools > Create Pool: IP
  #____________________________________________________________
  ip = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "ip", []) : merge(local.defaults.ip, v, {
      ipv4_blocks = [for e in lookup(v, "ipv4_blocks", []) : merge(local.defaults.ip.ipv4_blocks, e)]
      ipv4_config = [for e in [lookup(v, "ipv4_configuration", {})
      ] : merge(local.defaults.ip.ipv4_configuration, e) if length(lookup(v, "ipv4_configuration", {})) > 0]
      ipv6_blocks = [for e in lookup(v, "ipv6_blocks", []) : merge(local.defaults.ip.ipv6_blocks, e)]
      ipv6_config = [for e in [lookup(v, "ipv6_configuration", {})
      ] : merge(local.defaults.ip.ipv6_configuration, e) if length(lookup(v, "ipv6_configuration", {})) > 0]
      name = "${local.name_prefix[org].ip}${v.name}${local.name_suffix[org].ip}"
      org  = org
      tags = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "ip", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight IQN Pool
  # GUI Location: Pools > Create Pool: IQN
  #____________________________________________________________
  iqn = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "iqn", []) : merge(local.defaults.iqn, v, {
      iqn_blocks = [for e in lookup(v, "iqn_blocks", []) : merge(local.defaults.iqn.iqn_blocks, e)]
      name       = "${local.name_prefix[org].iqn}${v.name}${local.name_suffix[org].iqn}"
      org        = org
      tags       = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "iqn", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight MAC Pool
  # GUI Location: Pools > Create Pool: MAC
  #____________________________________________________________
  mac = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "mac", []) : merge(local.defaults.mac, v, {
      mac_blocks = [for e in lookup(v, "mac_blocks", []) : merge(local.defaults.mac.mac_blocks, e)]
      name       = "${local.name_prefix[org].mac}${v.name}${local.name_suffix[org].mac}"
      org        = org
      tags       = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "mac", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight Pool - Reservations
  #____________________________________________________________
  reservations_loop_1 = flatten([for org in keys(var.orgs) : [for s in lookup(lookup(lookup(var.model, org, {}), "profiles", {}), "server", []) : [
    for t in s.targets : [for r in lookup(t, "reservations", []) : merge(local.defaults.reservations, r, {
      org       = length(regexall("/", r.pool_name)) > 0 ? element(split("/", r.pool_name), 0) : org
      pool_name = length(regexall("/", r.pool_name)) > 0 ? element(split("/", r.pool_name), 1) : r.pool_name
    })]] if lookup(s, "ignore_reservations", false) == false]
  ])
  reservations = [for v in local.reservations_loop_1 : merge(v, {
    pool_name = "${v.org}/${local.npfx[v.org][v.identity_type]}${v.pool_name}${local.nsfx[v.org][v.identity_type]}"
  })]
  reservation = {
    ip   = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "ip"]))
    iqn  = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "iqn"]))
    mac  = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "mac"]))
    uuid = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "uuid"]))
    wwnn = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "wwnn"]))
    wwpn = distinct(compact([for v in local.reservations : v.pool_name if v.identity_type == "wwpn"]))
  }
  pp = {
    server_pool_qualification = distinct(compact(flatten([for v in local.resource : [for e in v.server_pool_qualification_policies : e if element(split("/", e), 1) != "UNUSED"]])))
  }
  policies = {
    server_pool_qualification = { keys = keys(local.server_pool_qualification), object = "resourcepool.QualificationPolicy" }
  }
  # policy_types = []
  policy_types = ["server_pool_qualification"]
  pools = {
    ip   = { moids = keys(local.ip), object = "ippool.Pool" }
    iqn  = { moids = keys(local.iqn), object = "iqnpool.Pool" }
    mac  = { moids = keys(local.mac), object = "macpool.Pool" }
    uuid = { moids = keys(local.uuid), object = "uuidpool.Pool" }
    wwnn = { moids = keys(local.wwnn), object = "fcpool.Pool" }
    wwpn = { moids = keys(local.wwpn), object = "fcpool.Pool" }
  }
  pool_types    = ["ip", "iqn", "mac", "uuid", "wwnn", "wwpn"]
  data_policies = { for e in local.policy_types : e => [for v in local.pp[e] : element(split("/", v), 1) if contains(local.policies[e].keys, v) == false] }
  data_pools = { for e in local.pool_types : e => [for v in local.reservation[e] : element(split("/", v), 1
  ) if contains(local.pools[e].moids, v) == false] }
  policies_data = { for k in keys(data.intersight_search_search_item.policies) : k => {
    for e in lookup(data.intersight_search_search_item.policies[k], "results", []
      ) : "${local.org_names[jsondecode(e.additional_properties).Organization.Moid]}/${jsondecode(e.additional_properties).Name}" => merge({
        additional_properties = jsondecode(e.additional_properties)
        moid                  = e.moid
    })
  } }
  pools_data = { for k in keys(data.intersight_search_search_item.pools) : k => {
    for e in lookup(data.intersight_search_search_item.pools[k], "results", []
      ) : "${local.org_names[jsondecode(e.additional_properties).Organization.Moid]}/${jsondecode(e.additional_properties).Name}" => merge({
        additional_properties = jsondecode(e.additional_properties)
        moid                  = e.moid
    })
  } }
  reservation_results = {
    ip   = { for v in sort(keys(intersight_ippool_reservation.map)) : v => intersight_ippool_reservation.map[v].moid }
    iqn  = { for v in sort(keys(intersight_iqnpool_reservation.map)) : v => intersight_iqnpool_reservation.map[v].moid }
    mac  = { for v in sort(keys(intersight_macpool_reservation.map)) : v => intersight_macpool_reservation.map[v].moid }
    uuid = { for v in sort(keys(intersight_uuidpool_reservation.map)) : v => intersight_uuidpool_reservation.map[v].moid }
    wwnn = { for v in sort(keys(intersight_fcpool_reservation.wwnn)) : v => intersight_fcpool_reservation.wwnn[v].moid }
    wwpn = { for v in sort(keys(intersight_fcpool_reservation.wwpn)) : v => intersight_fcpool_reservation.wwpn[v].moid }
  }

  #____________________________________________________________
  #
  # Intersight Server Pool Qualification Policy
  # GUI Location: Policies > Create Policy: Server Pool Qualification
  #____________________________________________________________
  qka  = { AdaptersRange = "number_of_network_adapters" }
  qkb  = { AssetTags = "asset_tags", ChassisPids = "chassis_pids", Pids = "blade_pids", UserLabels = "user_labels" }
  qkd  = { DomainNames = "domain_names", FabricInterConnectPids = "fabric_interconnect_pids" }
  qkc  = { CPUCoresRange = "number_of_cores", SpeedRange = "speed" }
  qkg  = { GpuControllersRange = "number_of_gpus" }
  qkm  = { MemoryCapacityRange = "capacity", MemoryUnitsRange = "number_of_units" }
  qko  = { CPUCoresRange = "resource.CPUCoreRangeFilter", SpeedRange = "resource.CpuSpeedRangeFilter" }
  qkr  = { AssetTags = "asset_tags", Pids = "rack_pids", UserLabels = "user_labels" }
  qkt  = { ChassisTags = "chassis_tags", DomainProfileTags = "domain_profile_tags", ServerTags = "server_tags" }
  spqt = ["adapter", "blade_server", "cpu", "domain", "gpu", "memory", "rack_server", "tag_qualifier"]
  server_pool_qualification = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.policies_model[org], "server_pool_qualification", []) : {
      adapter = length(lookup(lookup(v, "hardware_qualifiers", {}), "network_adapter", {})) > 0 ? {
        additional_properties = jsonencode({ for a, b in local.qka : a => {
          ConditionType = "RANGE"
          MaxValue      = lookup(lookup(v.hardware_qualifiers.network_adapter, b, {}), "maximum", 0)
          MinValue      = lookup(lookup(v.hardware_qualifiers.network_adapter, b, {}), "minimum", 0)
          ObjectType    = "${a}Filter"
        } })
        class_id    = "resource.NetworkAdaptorQualifier"
        object_type = "resource.NetworkAdaptorQualifier"
      } : {}
      blade_server = length(lookup(lookup(v, "server_qualifiers", {}), "blade_server", {})) > 0 ? {
        additional_properties = jsonencode(merge({ for a, b in local.qkb : a => lookup(v.server_qualifiers.blade_server, b, []) },
          { ChassisAndSlotIdRange = [for e in lookup(v.server_qualifiers.blade_server, "chassis_slot_qualifier", []) : {
            ChassisIdRange = {
              ClassId       = "resource.ChassisIdRangeFilter"
              ConditionType = "RANGE"
              MaxValue      = e.chassis_ids.to
              MinValue      = e.chassis_ids.from
              ObjectType    = "resource.ChassisIdRangeFilter"
            }
            ObjectType = "resource.ChassisAndSlotQualification"
            SlotIdRanges = [for d in lookup(e, "slot_ids", []) : {
              ClassId       = "resource.SlotIdRangeFilter"
              ConditionType = "RANGE"
              MaxValue      = d.to
              MinValue      = d.from
              ObjectType    = "resource.SlotIdRangeFilter"
            }]
        }] }))
        class_id    = "resource.BladeQualifier"
        object_type = "resource.BladeQualifier"
      } : {}
      cpu = length(lookup(lookup(v, "hardware_qualifiers", {}), "cpu", {})) > 0 ? {
        additional_properties = jsonencode(merge({ for a, b in local.qkc : a => {
          ConditionType = "RANGE"
          MaxValue      = lookup(lookup(v.hardware_qualifiers.cpu, b, {}), "maximum", 0)
          MinValue      = lookup(lookup(v.hardware_qualifiers.cpu, b, {}), "minimum", 0)
          ObjectType    = local.qko[a]
          } }, {
          Pids   = lookup(v.hardware_qualifiers.cpu, "pids", [])
          Vendor = lookup(v.hardware_qualifiers.cpu, "vendor", "")
        }))
        class_id    = "resource.ProcessorQualifier"
        object_type = "resource.ProcessorQualifier"
      } : {}
      description = lookup(v, "description", "")
      domain = length(lookup(v, "domain_qualifiers", {})) > 0 ? {
        additional_properties = jsonencode({ for a, b in local.qkd : a => lookup(v.domain_qualifiers, b, []) })
        class_id              = "resource.DomainQualifier"
        object_type           = "resource.DomainQualifier"
      } : {}
      gpu = {
        additional_properties = jsonencode(merge({ for a, b in local.qkg : a => {
          ConditionType = "RANGE"
          MaxValue      = lookup(lookup(lookup(lookup(v, "hardware_qualifiers", {}), "gpu", {}), b, {}), "maximum", 0)
          MinValue      = lookup(lookup(lookup(lookup(v, "hardware_qualifiers", {}), "gpu", {}), b, {}), "minimum", 0)
          ObjectType    = "resource.${a}Filter"
          } }, {
          GpuEvaluationType = lookup(lookup(lookup(v, "hardware_qualifiers", {}), "gpu", {}), "evaluation_type", "ServerWithoutGpu")
          Pids              = lookup(lookup(lookup(v, "hardware_qualifiers", {}), "gpu", {}), "pids", [])
          Vendor            = lookup(lookup(lookup(v, "hardware_qualifiers", {}), "gpu", {}), "vendor", "")
        }))
        class_id    = "resource.GpuQualifier"
        object_type = "resource.GpuQualifier"
      }
      memory = length(lookup(lookup(v, "hardware_qualifiers", {}), "memory", {})) > 0 ? {
        additional_properties = jsonencode({ for a, b in local.qkm : a => {
          ConditionType = "RANGE"
          MaxValue      = lookup(lookup(v.hardware_qualifiers.memory, b, {}), "maximum", 0)
          MinValue      = lookup(lookup(v.hardware_qualifiers.memory, b, {}), "minimum", 0)
          ObjectType    = "resource.${a}Filter"
        } })
        class_id    = "resource.MemoryQualifier"
        object_type = "resource.MemoryQualifier"
      } : {}
      name = "${local.ppfx[org].server_pool_qualification}${v.name}${local.psfx[org].server_pool_qualification}"
      org  = org
      rack_server = length(lookup(lookup(v, "server_qualifiers", {}), "rack_server", {})) > 0 ? {
        additional_properties = jsonencode(merge({
          for a, b in local.qkr : a => lookup(v.server_qualifiers.rack_server, b, []) },
          { RackIdRange = [for e in lookup(v.server_qualifiers.rack_server, "rack_ids", []) : {
            ConditionType = "RANGE"
            MaxValue      = e.to
            MinValue      = e.from
            ObjectType    = "resource.RackIdRangeFilter"
          }] }
        ))
        class_id    = "resource.RackServerQualifier"
        object_type = "resource.RackServerQualifier"
      } : {}
      tag_qualifier = length(lookup(v, "tag_qualifiers", {})) > 0 ? {
        additional_properties = jsonencode({
          for a, b in local.qkt : a => [
            for e in lookup(v.tag_qualifiers, b, []) : { Key = e.key, ObjectType = "resource.Tag", Value = e.value }
          ]
        })
        class_id    = "resource.TagQualifier"
        object_type = "resource.TagQualifier"
      } : {}
      tags = lookup(v, "tags", var.global_settings.tags)
    }
  ] if length(lookup(local.policies_model[org], "server_pool_qualification", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight Resource Pool
  # GUI Location: Pools > Create Pool: Resource
  #____________________________________________________________
  resource = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "resource", []) : merge(local.defaults.resource, v, {
      name = "${local.name_prefix[org].resource}${v.name}${local.name_suffix[org].resource}"
      org  = org
      server_pool_qualification_policies = [for e in [for d in lookup(v, "server_pool_qualification_policies", []) : {
        name = length(regexall("/", d)) > 0 ? element(split("/", d), 1) : d
        org  = length(regexall("/", d)) > 0 ? element(split("/", d), 0) : org
      }] : "${e.org}/${local.ppfx[e.org].server_pool_qualification}${e.name}${local.psfx[e.org].server_pool_qualification}"]
      tags = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "resource", [])) > 0]) : "${i.org}/${i.name}" => i }
  serial_number_list = flatten([for k, v in local.resource : v.static_resource_selection])

  #____________________________________________________________
  #
  # Intersight UUID Pool
  # GUI Location: Pools > Create Pool: UUID
  #____________________________________________________________
  uuid = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "uuid", []) : merge(local.defaults.uuid, v, {
      name        = "${local.name_prefix[org].uuid}${v.name}${local.name_suffix[org].uuid}"
      org         = org
      tags        = lookup(v, "tags", var.global_settings.tags)
      uuid_blocks = [for e in lookup(v, "uuid_blocks", []) : merge(local.defaults.uuid.uuid_blocks, e)]
    })
  ] if length(lookup(local.model[org], "uuid", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight WWNN Pool
  # GUI Location: Pools > Create Pool: WWNN
  #____________________________________________________________
  wwnn = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "wwnn", []) : merge(local.defaults.wwnn, v, {
      id_blocks = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwnn.id_blocks, e)]
      name      = "${local.name_prefix[org].wwnn}${v.name}${local.name_suffix[org].wwnn}"
      org       = org
      tags      = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "wwnn", [])) > 0]) : "${i.org}/${i.name}" => i }

  #____________________________________________________________
  #
  # Intersight WWPN Pool
  # GUI Location: Pools > Create Pool: WWPN
  #____________________________________________________________
  wwpn = { for i in flatten([for org in local.org_keys : [
    for v in lookup(local.model[org], "wwpn", []) : merge(local.defaults.wwpn, v, {
      id_blocks = [for e in lookup(v, "id_blocks", []) : merge(local.defaults.wwpn.id_blocks, e)]
      name      = "${local.name_prefix[org].wwpn}${v.name}${local.name_suffix[org].wwpn}"
      org       = org
      tags      = lookup(v, "tags", var.global_settings.tags)
    })
  ] if length(lookup(local.model[org], "wwpn", [])) > 0]) : "${i.org}/${i.name}" => i }
}
