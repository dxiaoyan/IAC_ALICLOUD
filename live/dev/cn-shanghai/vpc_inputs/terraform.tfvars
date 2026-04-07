# vpc_inputs settings for dev
# Static values are kept in tfvars; downstream modules consume output IDs.

create_vpc      = true
vpc_name        = "lilly-dev-vpc"
vpc_description = "Lilly dev VPC for IaC template"
vpc_cidr_block  = "10.210.0.0/16"

create_vswitch      = true
vswitch_name        = "lilly-dev-vsw-e"
vswitch_description = "Lilly dev ECS test vSwitch"
vswitch_cidr_block  = "10.210.0.0/20"
vswitch_zone_id     = "cn-shanghai-e"

# Keep these empty when VPC/vSwitch are created in this component.
existing_vpc_id     = ""
existing_vswitch_id = ""
