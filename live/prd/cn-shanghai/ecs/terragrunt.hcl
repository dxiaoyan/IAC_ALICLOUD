include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  components_vars = read_terragrunt_config(find_in_parent_folders("components.hcl"))
  component       = local.components_vars.locals[basename(get_terragrunt_dir())]
}

dependency "vpc_inputs" {
  config_path = "../vpc_inputs"
  mock_outputs = {
    vswitch_id     = "vsw-mock-plan"
    ecs_private_ip = "10.210.32.2"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "sg" {
  config_path = "../sg"
  mock_outputs = {
    security_group_id       = "sg-mock-plan"
    security_group_ids_list = ["sg-mock-plan"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}


dependencies {
  paths = ["../kms", "../vpc_inputs", "../sg"]
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../modules/${local.component}/terraform"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
provider "alicloud" {
  region = "${local.env_vars.locals.region}"
}
EOF
}

inputs = {
  global = local.env_vars.locals.global
  tags   = local.env_vars.locals.global.tags

  vswitch_id = trimspace(try(dependency.vpc_inputs.outputs.vswitch_id, ""))
  private_ip = try(dependency.vpc_inputs.outputs.ecs_private_ip, null)

  security_group_ids = try(length(dependency.sg.outputs.security_group_ids_list), 0) > 0 ? dependency.sg.outputs.security_group_ids_list : compact([trimspace(try(dependency.sg.outputs.security_group_id, ""))])
}


