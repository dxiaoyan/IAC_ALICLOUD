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

