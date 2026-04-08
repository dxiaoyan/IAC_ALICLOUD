# Module: vpc_inputs

This is a scaffold module for Lilly Alibaba Cloud IAC.

## Next Step

Implement resources and variables based on approved baseline and service design.

## Current Usage

This module reads `global.vpc.test_cidr` from environment configuration and exposes:

- `vpc_test_cidr`
- `vpc_test_gateway_ip`
- `vpc_test_first_host_ip`
