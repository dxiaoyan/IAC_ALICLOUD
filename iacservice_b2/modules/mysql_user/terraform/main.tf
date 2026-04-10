locals {
  module_name = "mysql_user"
}

data "alicloud_kms_secret_versions" "account_password" {
  count = var.create_mysql_user ? 1 : 0

  secret_name    = trimspace(var.kms_secret_name)
  version_stage  = trimspace(var.secret_version_stage)
  enable_details = true
}

locals {
  secret_data_raw = var.create_mysql_user ? trimspace(try(data.alicloud_kms_secret_versions.account_password[0].versions[0].secret_data, "")) : ""
  secret_data_map = can(jsondecode(local.secret_data_raw)) ? jsondecode(local.secret_data_raw) : {}

  account_password = try(trimspace(tostring(local.secret_data_map[var.secret_password_field])), "") != "" ? trimspace(tostring(local.secret_data_map[var.secret_password_field])) : local.secret_data_raw
}

resource "alicloud_rds_account" "this" {
  count = var.create_mysql_user ? 1 : 0

  db_instance_id       = trimspace(var.db_instance_id)
  account_name         = trimspace(var.account_name)
  account_password     = local.account_password
  account_description  = trimspace(var.account_description)
  account_type         = trimspace(var.account_type)

  lifecycle {
    precondition {
      condition     = trimspace(var.db_instance_id) != ""
      error_message = "When create_mysql_user=true, db_instance_id must be provided."
    }

    precondition {
      condition     = trimspace(var.kms_secret_name) != ""
      error_message = "When create_mysql_user=true, kms_secret_name must be provided."
    }

    precondition {
      condition     = trimspace(var.account_name) != ""
      error_message = "When create_mysql_user=true, account_name must be provided."
    }

    precondition {
      condition     = length(local.account_password) >= 8
      error_message = "Resolved account password from KMS secret must be at least 8 characters."
    }
  }
}

resource "alicloud_db_account_privilege" "this" {
  count = var.create_mysql_user && length(var.db_names) > 0 ? 1 : 0

  instance_id  = trimspace(var.db_instance_id)
  account_name = alicloud_rds_account.this[0].account_name
  privilege    = trimspace(var.privilege)
  db_names     = var.db_names
}
