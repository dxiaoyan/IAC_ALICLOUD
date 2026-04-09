# Module: vpc_inputs

This is a scaffold module for Lilly Alibaba Cloud IAC.

## Next Step

Implement resources and variables based on approved baseline and service design.

## Current Usage

This module reads `global.vpc.test_cidr` from environment configuration and exposes:

- `vpc_test_cidr`
- `vpc_test_gateway_ip`
- `vpc_test_first_host_ip`

## VPC Flow Log

To satisfy security baseline and KICS checks, this module supports optional VPC Flow Log creation:

- `enable_vpc_flow_log`: set to `true` to create flow log for VPC created by this module
- `flow_log_project_name`: target SLS project name
- `flow_log_store_name`: target SLS logstore name
- `vpc_flow_log_name`: optional override (defaults to `<vpc_name>-flowlog`)
- `vpc_flow_log_traffic_type`: `All` (default), `Allow`, or `Drop`
