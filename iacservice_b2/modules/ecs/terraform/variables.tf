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

variable "create_instance" {
  description = "Whether to create a single ECS instance in legacy mode"
  type        = bool
  default     = false
}

variable "instances" {
  description = "Multiple ECS instance definitions. When non-empty, module creates all instances in this list."
  type = list(object({
    instance_name              = string
    image_id                   = string
    instance_type              = optional(string)
    availability_zone          = optional(string)
    vswitch_id                 = optional(string)
    security_group_ids         = optional(list(string))
    private_ip                 = optional(string)
    instance_charge_type       = optional(string)
    period                     = optional(number)
    period_unit                = optional(string)
    internet_charge_type       = optional(string)
    internet_max_bandwidth_out = optional(number)
    system_disk_category       = optional(string)
    system_disk_size           = optional(number)
    key_name                   = optional(string)
    password                   = optional(string)
    user_data                  = optional(string)
    resource_group_id          = optional(string)
    tags                       = optional(map(string))
  }))
  default = []

  validation {
    condition     = length(var.instances) == length(distinct([for i in var.instances : i.instance_name]))
    error_message = "All instances[*].instance_name values must be unique."
  }

  validation {
    condition     = alltrue([for i in var.instances : trimspace(i.instance_name) != "" && trimspace(i.image_id) != ""])
    error_message = "Each instances item must define non-empty instance_name and image_id."
  }

  validation {
    condition = length(distinct(compact([
      for i in var.instances : try(trimspace(i.private_ip), "")
      ]))) == length(compact([
      for i in var.instances : try(trimspace(i.private_ip), "")
    ]))
    error_message = "instances[*].private_ip must be unique when specified."
  }
}

variable "instance_name" {
  description = "ECS instance name"
  type        = string
  default     = "lilly-dev-template-ecs-01"
}

variable "instance_type" {
  description = "ECS instance type"
  type        = string
  default     = "ecs.c6.large"
}

variable "availability_zone" {
  description = "Availability zone for ECS instance"
  type        = string
  default     = "cn-shanghai-h"
}

variable "image_id" {
  description = "Image ID for ECS instance"
  type        = string
  default     = ""
}

variable "vswitch_id" {
  description = "vSwitch ID for ECS instance"
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "Security group IDs for ECS instance"
  type        = list(string)
  default     = []
}

variable "private_ip" {
  description = "Fixed private IP for ECS instance (optional)"
  type        = string
  default     = null
}

variable "instance_charge_type" {
  description = "Instance charge type, PostPaid or PrePaid"
  type        = string
  default     = "PostPaid"
}

variable "period" {
  description = "Subscription period when instance_charge_type=PrePaid"
  type        = number
  default     = 1
}

variable "period_unit" {
  description = "Subscription period unit when instance_charge_type=PrePaid, Month or Week"
  type        = string
  default     = "Month"
}

variable "internet_charge_type" {
  description = "Internet charge type"
  type        = string
  default     = "PayByTraffic"
}

variable "internet_max_bandwidth_out" {
  description = "Public outbound bandwidth in Mbps (0 means no public IP)"
  type        = number
  default     = 0
}

variable "system_disk_category" {
  description = "System disk category"
  type        = string
  default     = "cloud_essd"
}

variable "system_disk_size" {
  description = "System disk size in GiB"
  type        = number
  default     = 80
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = ""
}

variable "password" {
  description = "ECS login password (use only when no key pair is used)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "user_data" {
  description = "Cloud-init user data script (plain text)"
  type        = string
  default     = ""
}

variable "resource_group_id" {
  description = "Resource Group ID for ECS instance"
  type        = string
  default     = null
}

