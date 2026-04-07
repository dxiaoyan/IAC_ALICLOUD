locals {
  module_name = "ecs"

  legacy_instance = {
    instance_name              = var.instance_name
    image_id                   = var.image_id
    instance_type              = var.instance_type
    availability_zone          = var.availability_zone
    vswitch_id                 = var.vswitch_id
    security_group_ids         = var.security_group_ids
    private_ip                 = var.private_ip
    instance_charge_type       = var.instance_charge_type
    period                     = var.period
    period_unit                = var.period_unit
    internet_charge_type       = var.internet_charge_type
    internet_max_bandwidth_out = var.internet_max_bandwidth_out
    system_disk_category       = var.system_disk_category
    system_disk_size           = var.system_disk_size
    key_name                   = var.key_name
    password                   = var.password
    user_data                  = var.user_data
    resource_group_id          = var.resource_group_id
    tags                       = {}
  }

  instances_raw = length(var.instances) > 0 ? var.instances : (var.create_instance ? [local.legacy_instance] : [])

  instances_effective = [
    for idx, inst in local.instances_raw : merge(
      local.legacy_instance,
      { for k, v in inst : k => v if v != null },
      {
        security_group_ids = try(length(inst.security_group_ids), 0) > 0 ? inst.security_group_ids : local.legacy_instance.security_group_ids
        private_ip = try(trimspace(inst.private_ip), "") != "" ? trimspace(inst.private_ip) : (
          length(var.instances) > 0 ? (idx == 0 ? local.legacy_instance.private_ip : null) : local.legacy_instance.private_ip
        )
        tags = try(inst.tags, null) != null ? inst.tags : local.legacy_instance.tags
      }
    )
  ]

  instance_map = {
    for idx, inst in local.instances_effective :
    format("%03d-%s", idx + 1, inst.instance_name) => inst
  }

  create_ecs = length(local.instance_map) > 0
}

resource "alicloud_instance" "this" {
  for_each = local.instance_map

  instance_name = each.value.instance_name
  image_id      = each.value.image_id
  instance_type = each.value.instance_type

  availability_zone = each.value.availability_zone
  vswitch_id        = each.value.vswitch_id
  security_groups   = each.value.security_group_ids
  private_ip        = try(trimspace(each.value.private_ip), "") != "" ? each.value.private_ip : null

  instance_charge_type       = each.value.instance_charge_type
  period                     = each.value.instance_charge_type == "PrePaid" ? each.value.period : null
  period_unit                = each.value.instance_charge_type == "PrePaid" ? each.value.period_unit : null
  internet_charge_type       = each.value.internet_charge_type
  internet_max_bandwidth_out = each.value.internet_max_bandwidth_out

  system_disk_category = each.value.system_disk_category
  system_disk_size     = each.value.system_disk_size

  key_name = try(trimspace(each.value.key_name), "") != "" ? each.value.key_name : null
  password = try(trimspace(each.value.password), "") != "" ? each.value.password : null

  user_data         = try(trimspace(each.value.user_data), "") != "" ? base64encode(each.value.user_data) : null
  resource_group_id = try(each.value.resource_group_id, null)
  tags              = merge(var.tags, each.value.tags, { Name = each.value.instance_name })

  lifecycle {
    precondition {
      condition     = trimspace(each.value.image_id) != ""
      error_message = "Each ECS instance must provide image_id."
    }

    precondition {
      condition     = try(trimspace(each.value.vswitch_id), "") != ""
      error_message = "Each ECS instance must provide vswitch_id (from dependency vpc_inputs output)."
    }

    precondition {
      condition     = length(each.value.security_group_ids) > 0
      error_message = "Each ECS instance must provide at least one security group ID (from dependency sg output)."
    }

    precondition {
      condition     = try(trimspace(each.value.key_name), "") != "" || try(trimspace(each.value.password), "") != ""
      error_message = "Each ECS instance must provide key_name or password."
    }
  }
}
