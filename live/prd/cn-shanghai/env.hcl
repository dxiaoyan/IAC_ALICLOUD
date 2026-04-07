locals {
  env_name = "prd"
  region   = "cn-shanghai"

  global = {
    project     = "lilly"
    environment = "prd"
    region      = "cn-shanghai"
    timezone    = "Asia/Shanghai"
    vpc = {
      # VPC test CIDR for prd
      test_cidr = "10.210.32.0/20"
      # These IDs should come from the network component/account factory output.
      # Keep empty until real IDs are ready.
      vpc_id         = ""
      vswitch_id     = ""
      ecs_private_ip = ""
    }

    tags = {
      Project     = "lilly"
      Environment = "prd"
      ManagedBy   = "terraform-terragrunt"
      Owner       = "platform"
    }
  }
}
