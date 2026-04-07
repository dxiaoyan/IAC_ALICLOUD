# create_instance = true
# instance_name     = "lilly-dev-template-ecs-01"
# instance_type     = "ecs.c6.large"
# availability_zone = "cn-shanghai-e"
# image_id          = "aliyun_3_x64_20G_alibase_20260122.vhd"
#
# instance_charge_type       = "PostPaid"
# internet_charge_type       = "PayByTraffic"
# internet_max_bandwidth_out = 0
# system_disk_category       = "cloud_essd"
# system_disk_size           = 80
#
# key_name = "lilly-dev-keypair"
# password = ""
#
# user_data = <<-EOF
# #!/bin/bash
# set -e
# hostnamectl set-hostname lilly-dev-template-ecs-01
# EOF

# Batch mode example (recommended when creating multiple ECS instances):
create_instance = true
instances = [
  {
    instance_name = "lilly-dev-app-01"
    instance_type     = "ecs.c6.large"
    availability_zone = "cn-shanghai-e"
    image_id          = "aliyun_3_x64_20G_alibase_20260122.vhd"

    instance_charge_type       = "PostPaid"
    internet_charge_type       = "PayByTraffic"
    internet_max_bandwidth_out = 0
    system_disk_category       = "cloud_essd"
    system_disk_size           = 80

    key_name = "lilly-dev-keypair"
    password = ""

    user_data = <<-EOF
#!/bin/bash
set -e
hostnamectl set-hostname lilly-dev-template-ecs-01
EOF
  },
  {
    instance_name = "lilly-dev-app-02"
    instance_type     = "ecs.c6.large"
    availability_zone = "cn-shanghai-e"
    image_id          = "aliyun_3_x64_20G_alibase_20260122.vhd"

    instance_charge_type       = "PostPaid"
    internet_charge_type       = "PayByTraffic"
    internet_max_bandwidth_out = 0
    system_disk_category       = "cloud_essd"
    system_disk_size           = 80

    key_name = "lilly-dev-keypair"
    password = ""

    user_data = <<-EOF
#!/bin/bash
set -e
hostnamectl set-hostname lilly-dev-template-ecs-01
EOF
  }
]
