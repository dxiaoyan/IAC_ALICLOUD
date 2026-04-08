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

variable "create_security_group" {
  description = "Whether to create the security group and rules"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "Additional security groups to create in batch mode"
  type = list(object({
    security_group_name        = string
    security_group_description = optional(string, "Managed by Terraform")
    vpc_id                     = optional(string)
    ingress_rules = optional(list(object({
      description = optional(string, "")
      ip_protocol = string
      nic_type    = optional(string, "intranet")
      policy      = optional(string, "accept")
      port_range  = string
      priority    = optional(number, 1)
      cidr_ip     = string
    })), [])
    egress_rules = optional(list(object({
      description = optional(string, "")
      ip_protocol = string
      nic_type    = optional(string, "intranet")
      policy      = optional(string, "accept")
      port_range  = string
      priority    = optional(number, 1)
      cidr_ip     = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length(var.security_groups) == length(distinct([for sg in var.security_groups : sg.security_group_name]))
    error_message = "security_groups[*].security_group_name must be unique."
  }
}

variable "security_group_name" {
  description = "Security group name"
  type        = string
  default     = "lilly-dev-template-sg"
}

variable "security_group_description" {
  description = "Security group description"
  type        = string
  default     = "Template security group for Lilly dev ECS workloads"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
  default     = ""

  validation {
    condition = (
      (!var.create_security_group || trimspace(var.vpc_id) != "") &&
      alltrue([
        for sg in var.security_groups : trimspace(try(sg.vpc_id, "")) != "" || trimspace(var.vpc_id) != ""
      ])
    )
    error_message = "When creating SG, vpc_id must be provided either at module level or per security_groups item."
  }
}

variable "ingress_rules" {
  description = "Ingress rules for the security group"
  type = list(object({
    description = optional(string, "")
    ip_protocol = string
    nic_type    = optional(string, "intranet")
    policy      = optional(string, "accept")
    port_range  = string
    priority    = optional(number, 1)
    cidr_ip     = string
  }))
  default = [
    {
      description = "Allow SSH from test network"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "10.210.0.0/20"
    },
    {
      description = "Allow HTTPS from test network"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "10.210.0.0/20"
    }
  ]
}

variable "egress_rules" {
  description = "Egress rules for the security group"
  type = list(object({
    description = optional(string, "")
    ip_protocol = string
    nic_type    = optional(string, "intranet")
    policy      = optional(string, "accept")
    port_range  = string
    priority    = optional(number, 1)
    cidr_ip     = string
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      ip_protocol = "all"
      port_range  = "-1/-1"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}
