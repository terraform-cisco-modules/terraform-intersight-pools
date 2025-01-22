output "spq" {
  value = local.server_pool_qualification
}

output "server_pool_qualification" {
  value = intersight_resourcepool_qualification_policy.map
}