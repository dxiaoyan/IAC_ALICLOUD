output "module_name" {
  value       = local.module_name
  description = "Module identifier"
}

output "created" {
  value       = var.create_mysql_user
  description = "Whether this module created MySQL account"
}

output "account_name" {
  value       = var.create_mysql_user ? alicloud_rds_account.this[0].account_name : null
  description = "Created MySQL account name"
}

output "db_instance_id" {
  value       = var.create_mysql_user ? alicloud_rds_account.this[0].db_instance_id : null
  description = "Target RDS instance ID"
}
