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

variable "create_vpc" {
  description = "Whether to create a VPC in this component"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "VPC name when create_vpc=true"
  type        = string
  default     = "lilly-dev-vpc"
}

variable "vpc_description" {
  description = "VPC description when create_vpc=true"
  type        = string
  default     = "Lilly VPC managed by Terraform"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block when create_vpc=true"
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.vpc_cidr_block) == "" || can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "vpc_cidr_block must be a valid CIDR when specified."
  }
}

variable "existing_vpc_id" {
  description = "Existing VPC ID fallback when create_vpc=false and global.vpc.vpc_id is empty"
  type        = string
  default     = ""
}

variable "create_vswitch" {
  description = "Whether to create a vSwitch in this component"
  type        = bool
  default     = false
}

variable "vswitch_name" {
  description = "vSwitch name when create_vswitch=true"
  type        = string
  default     = "lilly-dev-vsw-h"
}

variable "vswitch_description" {
  description = "vSwitch description when create_vswitch=true"
  type        = string
  default     = "Lilly vSwitch managed by Terraform"
}

variable "vswitch_cidr_block" {
  description = "vSwitch CIDR block when create_vswitch=true"
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.vswitch_cidr_block) == "" || can(cidrhost(var.vswitch_cidr_block, 0))
    error_message = "vswitch_cidr_block must be a valid CIDR when specified."
  }
}

variable "vswitch_zone_id" {
  description = "vSwitch zone_id when create_vswitch=true, for example cn-shanghai-h"
  type        = string
  default     = ""

  validation {
    condition     = var.vswitch_zone_id == "" || trimspace(var.vswitch_zone_id) != ""
    error_message = "vswitch_zone_id cannot be whitespace only."
  }
}

variable "existing_vswitch_id" {
  description = "Existing vSwitch ID fallback when create_vswitch=false and global.vpc.vswitch_id is empty"
  type        = string
  default     = ""
}

variable "enable_vpc_flow_log" {
  description = "Whether to create VPC flow log for the VPC created by this module"
  type        = bool
  default     = false
}

variable "vpc_flow_log_name" {
  description = "Flow log name. When empty, defaults to <vpc_name>-flowlog"
  type        = string
  default     = ""
}

variable "flow_log_project_name" {
  description = "SLS project name for VPC flow logs when enable_vpc_flow_log=true"
  type        = string
  default     = ""
}

variable "flow_log_store_name" {
  description = "SLS logstore name for VPC flow logs when enable_vpc_flow_log=true"
  type        = string
  default     = ""
}

variable "vpc_flow_log_traffic_type" {
  description = "VPC flow log traffic type: All, Allow, or Drop"
  type        = string
  default     = "All"

  validation {
    condition     = contains(["All", "Allow", "Drop"], var.vpc_flow_log_traffic_type)
    error_message = "vpc_flow_log_traffic_type must be one of: All, Allow, Drop."
  }
}

