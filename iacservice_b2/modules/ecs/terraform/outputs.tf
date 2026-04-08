output "module_name" {
  value       = local.module_name
  description = "Module identifier"
}

output "created" {
  value       = local.create_ecs
  description = "Whether this module created ECS instance(s)"
}

output "instance_id" {
  value       = local.create_ecs ? alicloud_instance.this[sort(keys(alicloud_instance.this))[0]].id : null
  description = "First ECS instance ID (for backward compatibility)"
}

output "instance_name" {
  value       = local.create_ecs ? alicloud_instance.this[sort(keys(alicloud_instance.this))[0]].instance_name : var.instance_name
  description = "First ECS instance name (for backward compatibility)"
}

output "private_ip" {
  value       = local.create_ecs ? alicloud_instance.this[sort(keys(alicloud_instance.this))[0]].private_ip : var.private_ip
  description = "First ECS private IP (for backward compatibility)"
}

output "instance_ids" {
  value       = { for k, v in alicloud_instance.this : k => v.id }
  description = "All ECS instance IDs"
}

output "instance_names" {
  value       = { for k, v in alicloud_instance.this : k => v.instance_name }
  description = "All ECS instance names"
}

output "private_ips" {
  value       = { for k, v in alicloud_instance.this : k => v.private_ip }
  description = "All ECS private IPs"
}

output "security_group_ids" {
  value       = distinct(flatten([for inst in values(local.instance_map) : inst.security_group_ids]))
  description = "Distinct bound security group IDs across all instances"
}

output "security_group_ids_by_instance" {
  value       = { for k, inst in local.instance_map : k => inst.security_group_ids }
  description = "Bound security group IDs per instance"
}
