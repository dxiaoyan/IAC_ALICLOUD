locals {
  module_name = "vpc_inputs"

  # Account factory or this module can provide real VPC/vSwitch IDs.
  # Downstream modules always consume normalized outputs from this module.
  vpc_test_cidr        = try(var.global.vpc.test_cidr, null)
  input_vpc_id         = trimspace(try(var.global.vpc.vpc_id, ""))
  input_vswitch_id     = trimspace(try(var.global.vpc.vswitch_id, ""))
  ecs_private_ip_input = try(var.global.vpc.ecs_private_ip, null)

  upstream_vpc_id     = local.input_vpc_id != "" ? local.input_vpc_id : trimspace(var.existing_vpc_id)
  upstream_vswitch_id = local.input_vswitch_id != "" ? local.input_vswitch_id : trimspace(var.existing_vswitch_id)

  vpc_id     = var.create_vpc ? alicloud_vpc.this[0].id : (local.upstream_vpc_id != "" ? local.upstream_vpc_id : null)
  vswitch_id = var.create_vswitch ? alicloud_vswitch.this[0].id : (local.upstream_vswitch_id != "" ? local.upstream_vswitch_id : null)

  vpc_test_cidr_valid = local.vpc_test_cidr != null && can(cidrhost(local.vpc_test_cidr, 0))
  ecs_private_ip      = try(trimspace(local.ecs_private_ip_input), "") != "" ? trimspace(local.ecs_private_ip_input) : (local.vpc_test_cidr_valid ? cidrhost(local.vpc_test_cidr, 2) : null)
}

resource "alicloud_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  vpc_name    = var.vpc_name
  cidr_block  = var.vpc_cidr_block
  description = var.vpc_description
  tags        = var.tags

  lifecycle {
    precondition {
      condition     = trimspace(var.vpc_cidr_block) != "" && can(cidrhost(var.vpc_cidr_block, 0))
      error_message = "When create_vpc=true, vpc_cidr_block must be provided as a valid CIDR."
    }
  }
}

resource "alicloud_vswitch" "this" {
  count = var.create_vswitch ? 1 : 0

  vpc_id = var.create_vpc ? alicloud_vpc.this[0].id : local.upstream_vpc_id

  cidr_block   = var.vswitch_cidr_block
  zone_id      = var.vswitch_zone_id
  vswitch_name = var.vswitch_name
  description  = var.vswitch_description
  tags         = var.tags

  lifecycle {
    precondition {
      condition     = trimspace(var.vswitch_cidr_block) != "" && can(cidrhost(var.vswitch_cidr_block, 0))
      error_message = "When create_vswitch=true, vswitch_cidr_block must be provided as a valid CIDR."
    }

    precondition {
      condition     = trimspace(var.vswitch_zone_id) != ""
      error_message = "When create_vswitch=true, vswitch_zone_id must be provided."
    }

    precondition {
      condition     = trimspace(var.create_vpc ? alicloud_vpc.this[0].id : local.upstream_vpc_id) != ""
      error_message = "When create_vswitch=true, an upstream vpc_id (or create_vpc=true) is required."
    }
  }
}
