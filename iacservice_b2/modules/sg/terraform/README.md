# Module: sg

Alibaba Cloud security group module for Lilly IAC.

## Features

- Create one primary security group and optional additional security groups in batch mode.
- Manage ingress and egress rules with structured inputs.
- Support template mode via `create_security_group = false` (no resource created).

## Key Inputs

- `create_security_group`: enable or disable real resource creation.
- `vpc_id`: target VPC ID.
- `security_group_name`, `security_group_description`.
- `ingress_rules`, `egress_rules`: list of rule objects.
- `security_groups`: batch security group definitions (optional).
