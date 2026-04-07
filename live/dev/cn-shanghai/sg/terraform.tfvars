create_security_group      = true
security_group_name        = "lilly-dev-template-sg"
security_group_description = "Template SG for Lilly dev ECS workloads"

ingress_rules = [
  {
    description = "Allow SSH from dev test CIDR"
    ip_protocol = "tcp"
    nic_type    = "intranet"
    policy      = "accept"
    port_range  = "22/22"
    priority    = 10
    cidr_ip     = "10.210.0.0/20"
  },
  {
    description = "Allow HTTPS from dev test CIDR"
    ip_protocol = "tcp"
    nic_type    = "intranet"
    policy      = "accept"
    port_range  = "443/443"
    priority    = 20
    cidr_ip     = "10.210.0.0/20"
  }
]

egress_rules = [
  {
    description = "Allow all outbound traffic"
    ip_protocol = "all"
    nic_type    = "intranet"
    policy      = "accept"
    port_range  = "-1/-1"
    priority    = 1
    cidr_ip     = "0.0.0.0/0"
  }
]

# Batch mode example (additional security groups):
# security_groups = [
#   {
#     security_group_name        = "lilly-dev-app-sg"
#     security_group_description = "App SG"
#     ingress_rules = [
#       {
#         description = "Allow 8080 from test CIDR"
#         ip_protocol = "tcp"
#         port_range  = "8080/8080"
#         cidr_ip     = "10.210.0.0/20"
#       }
#     ]
#     egress_rules = [
#       {
#         description = "Allow all outbound"
#         ip_protocol = "all"
#         port_range  = "-1/-1"
#         cidr_ip     = "0.0.0.0/0"
#       }
#     ]
#   }
# ]
