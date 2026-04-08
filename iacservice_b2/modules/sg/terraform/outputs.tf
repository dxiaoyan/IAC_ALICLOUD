output "module_name" {
  value       = local.module_name
  description = "Module identifier"
}

output "created" {
  value       = local.create_sg
  description = "Whether this module created security group resources"
}

output "security_group_id" {
  value = local.create_primary_sg ? alicloud_security_group.this[0].id : (
    length(alicloud_security_group.extra) > 0 ? alicloud_security_group.extra[sort(keys(alicloud_security_group.extra))[0]].id : null
  )
  description = "Primary security group ID for backward compatibility"
}

output "security_group_name" {
  value = local.create_primary_sg ? alicloud_security_group.this[0].security_group_name : (
    length(alicloud_security_group.extra) > 0 ? alicloud_security_group.extra[sort(keys(alicloud_security_group.extra))[0]].security_group_name : var.security_group_name
  )
  description = "Primary security group name for backward compatibility"
}

output "security_group_ids_list" {
  value = concat(
    local.create_primary_sg ? [alicloud_security_group.this[0].id] : [],
    [for sg in values(alicloud_security_group.extra) : sg.id]
  )
  description = "All created security group IDs"
}

output "security_group_ids_map" {
  value = merge(
    local.create_primary_sg ? { primary = alicloud_security_group.this[0].id } : {},
    { for k, sg in alicloud_security_group.extra : k => sg.id }
  )
  description = "Security group IDs map"
}

output "ingress_rule_ids" {
  value = concat(
    [for rule in values(alicloud_security_group_rule.ingress) : rule.id],
    [for rule in values(alicloud_security_group_rule.extra_ingress) : rule.id]
  )
  description = "Ingress rule IDs"
}

output "egress_rule_ids" {
  value = concat(
    [for rule in values(alicloud_security_group_rule.egress) : rule.id],
    [for rule in values(alicloud_security_group_rule.extra_egress) : rule.id]
  )
  description = "Egress rule IDs"
}
