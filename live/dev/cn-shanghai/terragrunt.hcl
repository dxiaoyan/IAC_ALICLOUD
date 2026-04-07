remote_state {
  backend = "oss"
  config = {
    bucket           = "lilly-iac-tfstate-cn-shanghai"
    key              = "live/dev/cn-shanghai/${path_relative_to_include()}/terraform.tfstate"
    region           = "cn-shanghai"
    acl              = "private"
    encrypt          = true
    tablestore_table = "lily_iac_tf_table"

    tablestore_endpoint = get_env("ALICLOUD_TABLESTORE_ENDPOINT")
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
