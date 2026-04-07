locals {
  env_name = "qa"
  region   = "cn-shanghai"

  global = {
    project     = "lilly"
    environment = "qa"
    region      = "cn-shanghai"
    timezone    = "Asia/Shanghai"
    vpc = {
      # VPC test CIDR for qa
      test_cidr = "10.210.16.0/20"
      # These IDs should come from the network component/account factory output.
      # Keep empty until real IDs are ready.
      vpc_id         = ""
      vswitch_id     = ""
      ecs_private_ip = ""
    }

    tags = {
      Project     = "lilly"
      Environment = "qa"
      ManagedBy   = "terraform-terragrunt"
      Owner       = "platform"
    }
  }
}
