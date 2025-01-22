locals {
  global_settings = {
    tags = [
      {
        key   = "Module"
        value = "easy-imm"
      },
      {
        key   = "Version"
        value = "4.2.11-18370"
      }
    ]
  }
  intersight_fqdn = lookup(local.global_settings, "intersight_fqdn", "intersight.com")
  model1          = yamldecode(file("${path.module}/policies/p.yaml"))
  model           = { for org in local.org_keys : org => lookup(local.model1[org], "pools", {}) }
  org_keys        = sort(keys(local.model1))
  orgs            = { for k, v in data.intersight_organization_organization.orgs.results : v.name => v.moid }

  policies_model  = { for org in local.org_keys : org => lookup(local.model1[org], "policies", {}) }
  policy_defaults = yamldecode(file("${path.module}/defaults.yaml")).policies
  policy_names    = ["server_pool_qualification"]
  ppfx = { for org in keys(local.orgs) : org => {
    for e in local.policy_names : e => lookup(lookup(lookup(lookup(local.model1, org, {}), "policies", {}), "name_prefix", {}
    ), e, lookup(lookup(lookup(lookup(local.model1, org, {}), "policies", {}), "name_prefix", local.policy_defaults.name_prefix), "default", ""))
  } }
  psfx = { for org in keys(local.orgs) : org => {
    for e in local.policy_names : e => lookup(lookup(lookup(lookup(local.model1, org, {}), "policies", {}), "name_suffix", {}
    ), e, lookup(lookup(lookup(lookup(local.model1, org, {}), "policies", {}), "name_suffix", local.policy_defaults.name_suffix), "default", ""))
  } }
  qka  = { AdaptersRange = "number_of_network_adapters" }
  qkb  = { AssetTags = "asset_tags", ChassisPids = "chassis_pids", Pids = "blade_pids", UserLabels = "user_labels" }
  qkd  = { DomainNames = "domain_names", FabricInterConnectPids = "fabric_interconnect_pids" }
  qkc  = { CPUCoresRange = "number_of_cores", SpeedRange = "speed" }
  qkg  = { GpuControllersRange = "number_of_gpus" }
  qkm  = { MemoryCapacityRange = "capacity", MemoryUnitsRange = "number_of_units" }
  qko  = { CPUCoresRange = "CPUCoreRangeFilter", SpeedRange = "CpuSpeedRangeFilter" }
  qkr  = { AssetTags = "asset_tags", Pids = "rack_pids", UserLabels = "user_labels" }
  qkt  = { ChassisTags = "chassis_tags", DomainProfileTags = "domain_profile_tags", ServerTags = "server_tags" }
  spq  = local.policy_defaults.server_pool_qualification
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
              #ClassId    = "resource.ChassisIdRangeFilter"
              ConditionType = "RANGE"
              MaxValue      = e.chassis_ids.to
              MinValue      = e.chassis_ids.from
              ObjectType    = "resource.ChassisIdRangeFilter"
            }
            ObjectType = "resource.ChassisAndSlotQualification"
            SlotIdRanges = [for d in lookup(e, "slot_ids", []) : {
              #ClassId    = "resource.SlotIdRangeFilter"
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
          ObjectType    = "${a}Filter"
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
          ObjectType    = "${a}Filter"
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
      tags = lookup(v, "tags", local.global_settings.tags)
    }
  ] if length(lookup(local.policies_model[org], "server_pool_qualification", [])) > 0]) : "${i.org}/${i.name}" => i }

}