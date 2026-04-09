locals {
  module_name       = "sg"
  create_primary_sg = var.create_security_group
  additional_sgs = {
    for idx, sg in var.security_groups :
    format("%03d-%s", idx + 1, sg.security_group_name) => sg
  }
  create_sg = local.create_primary_sg || length(local.additional_sgs) > 0
}

resource "alicloud_security_group" "this" {
  count = local.create_primary_sg ? 1 : 0

  security_group_name = var.security_group_name
  description         = var.security_group_description
  vpc_id              = var.vpc_id
  tags                = var.tags

  lifecycle {
    precondition {
      condition     = try(trimspace(var.vpc_id), "") != ""
      error_message = "When create_security_group=true, vpc_id must be provided."
    }
  }
}

resource "alicloud_security_group" "extra" {
  for_each = local.additional_sgs

  security_group_name = each.value.security_group_name
  description         = each.value.security_group_description
  vpc_id              = trimspace(try(each.value.vpc_id, "")) != "" ? each.value.vpc_id : var.vpc_id
  tags                = merge(var.tags, try(each.value.tags, {}))

  lifecycle {
    precondition {
      condition     = try(trimspace(each.value.vpc_id), "") != "" || try(trimspace(var.vpc_id), "") != ""
      error_message = "Each security_groups item must provide vpc_id or module-level vpc_id must be set."
    }
  }
}

resource "alicloud_security_group_rule" "ingress" {
  for_each = local.create_primary_sg ? { for idx, rule in var.ingress_rules : tostring(idx) => rule } : {}

  type              = "ingress"
  security_group_id = alicloud_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  cidr_ip           = each.value.cidr_ip
  description       = each.value.description
}

resource "alicloud_security_group_rule" "egress" {
  for_each = local.create_primary_sg ? { for idx, rule in var.egress_rules : tostring(idx) => rule } : {}

  type              = "egress"
  security_group_id = alicloud_security_group.this[0].id
  ip_protocol       = each.value.ip_protocol
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  cidr_ip           = each.value.cidr_ip
  description       = each.value.description
}

locals {
  extra_ingress_rules = flatten([
    for sg_key, sg in local.additional_sgs : [
      for idx, rule in try(sg.ingress_rules, []) : {
        key    = format("%s-ing-%03d", sg_key, idx + 1)
        sg_key = sg_key
        rule   = rule
      }
    ]
  ])
  extra_egress_rules = flatten([
    for sg_key, sg in local.additional_sgs : [
      for idx, rule in try(sg.egress_rules, []) : {
        key    = format("%s-egr-%03d", sg_key, idx + 1)
        sg_key = sg_key
        rule   = rule
      }
    ]
  ])
}

resource "alicloud_security_group_rule" "extra_ingress" {
  for_each = { for item in local.extra_ingress_rules : item.key => item }

  type              = "ingress"
  security_group_id = alicloud_security_group.extra[each.value.sg_key].id
  ip_protocol       = each.value.rule.ip_protocol
  nic_type          = each.value.rule.nic_type
  policy            = each.value.rule.policy
  port_range        = each.value.rule.port_range
  priority          = each.value.rule.priority
  cidr_ip           = each.value.rule.cidr_ip
  description       = each.value.rule.description
}

resource "alicloud_security_group_rule" "extra_egress" {
  for_each = { for item in local.extra_egress_rules : item.key => item }

  type              = "egress"
  security_group_id = alicloud_security_group.extra[each.value.sg_key].id
  ip_protocol       = each.value.rule.ip_protocol
  nic_type          = each.value.rule.nic_type
  policy            = each.value.rule.policy
  port_range        = each.value.rule.port_range
  priority          = each.value.rule.priority
  cidr_ip           = each.value.rule.cidr_ip
  description       = each.value.rule.description
}
