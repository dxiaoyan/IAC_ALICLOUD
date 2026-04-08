# Module: ecs

Alibaba Cloud ECS module for Lilly IAC.

## Features

- Create one ECS instance (legacy mode) or multiple ECS instances (batch mode).
- Support template mode via `create_instance = false` (no resource created).
- Validate required parameters when instance creation is enabled.

## Key Inputs

- `create_instance`
- `instances` (recommended for batch creation)
- `instance_name`, `instance_type`, `image_id`
- `availability_zone`, `vswitch_id`, `security_group_ids`, `private_ip`
- `key_name` or `password`
