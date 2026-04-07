variable "global" {
  description = "Global settings for environment and platform"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "enabled" {
  description = "Whether to create KMS keys in this module"
  type        = bool
  default     = true
}

variable "key_definitions" {
  description = "KMS key definitions by logical name"
  type = map(object({
    description                     = optional(string, "")
    alias_name                      = optional(string, "")
    pending_window_in_days          = optional(number, 30)
    status                          = optional(string, "Enabled")
    key_spec                        = optional(string, "Aliyun_AES_256")
    key_usage                       = optional(string, "ENCRYPT/DECRYPT")
    origin                          = optional(string, "Aliyun_KMS")
    protection_level                = optional(string, "SOFTWARE")
    automatic_rotation              = optional(string, "Disabled")
    rotation_interval               = optional(string, null)
    deletion_protection             = optional(string, "Enabled")
    deletion_protection_description = optional(string, null)
    policy                          = optional(string, null)
    tags                            = optional(map(string), {})
  }))
  default = {}
}

