variable "create_mysql_user" {
  description = "Whether to create MySQL account on RDS instance"
  type        = bool
  default     = false
}

variable "db_instance_id" {
  description = "RDS instance ID where account will be created"
  type        = string
  default     = ""
}

variable "account_name" {
  description = "MySQL account name"
  type        = string
  default     = "userA"
}

variable "account_description" {
  description = "MySQL account description"
  type        = string
  default     = "Managed by IaCService B2"
}

variable "account_type" {
  description = "MySQL account type: Normal or Super"
  type        = string
  default     = "Normal"
}

variable "kms_secret_name" {
  description = "KMS secret name used to fetch account password"
  type        = string
  default     = ""
}

variable "secret_version_stage" {
  description = "KMS secret version stage, usually ACSCurrent"
  type        = string
  default     = "ACSCurrent"
}

variable "secret_password_field" {
  description = "Password field key when secret data is JSON"
  type        = string
  default     = "password"
}

variable "db_names" {
  description = "Optional database names to grant privilege for this account"
  type        = list(string)
  default     = []
}

variable "privilege" {
  description = "Privilege to grant when db_names is not empty: ReadOnly, ReadWrite, DDLOnly, DBOwner"
  type        = string
  default     = "ReadOnly"
}
