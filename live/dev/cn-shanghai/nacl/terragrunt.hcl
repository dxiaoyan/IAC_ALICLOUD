include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  env_vars        = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  components_vars = read_terragrunt_config(find_in_parent_folders("components.hcl"))
  component       = local.components_vars.locals[basename(get_terragrunt_dir())]
}


dependencies {
  paths = ["../vpc_inputs"]
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
}


