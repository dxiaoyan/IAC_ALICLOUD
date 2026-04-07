remote_state {
  backend = "oss"
  config = {
    bucket           = "lilly-iac-tfstate-cn-shanghai"
    key              = "${path_relative_to_include()}/terraform.tfstate"
    region           = "cn-shanghai"
    acl              = "private"
    encrypt          = true
    tablestore_table = "lily_iac_tf_table"
    # IMPORTANT:
    # Set explicit Tablestore endpoint/instance to avoid OSS backend lock init issues.
    # Example endpoint: https://<your-ots-instance>.cn-shanghai.ots.aliyuncs.com
    tablestore_endpoint      = get_env("ALICLOUD_TABLESTORE_ENDPOINT")
    tablestore_instance_name = get_env("ALICLOUD_TABLESTORE_INSTANCE")
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
