output "module_name" {
  value       = local.module_name
  description = "Module identifier"
}

output "created_vpc" {
  value       = var.create_vpc
  description = "Whether this module is configured to create a VPC"
}

output "created_vswitch" {
  value       = var.create_vswitch
  description = "Whether this module is configured to create a vSwitch"
}

output "vpc_test_cidr" {
  value       = local.vpc_test_cidr
  description = "Configured VPC test CIDR from environment settings"
}

output "vpc_test_gateway_ip" {
  value       = local.vpc_test_cidr_valid ? cidrhost(local.vpc_test_cidr, 1) : null
  description = "Suggested gateway IP for the VPC test CIDR"
}

output "vpc_test_first_host_ip" {
  value       = local.vpc_test_cidr_valid ? cidrhost(local.vpc_test_cidr, 2) : null
  description = "Suggested first usable host IP for the VPC test CIDR"
}

output "vpc_id" {
  value       = local.vpc_id
  description = "VPC ID consumed by downstream modules"
}

output "vswitch_id" {
  value       = local.vswitch_id
  description = "vSwitch ID consumed by downstream modules"
}

output "ecs_private_ip" {
  value       = local.ecs_private_ip
  description = "Recommended ECS private IP for downstream modules"
}
