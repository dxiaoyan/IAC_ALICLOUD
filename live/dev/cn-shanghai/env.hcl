locals {
  env_name = "dev"
  region   = "cn-shanghai"

  global = {
    project     = "lilly"
    environment = "dev"
    region      = "cn-shanghai"
    timezone    = "Asia/Shanghai"
    vpc = {
      # VPC test CIDR for dev
      test_cidr = "10.210.0.0/20"
      # These IDs should come from the network component/account factory output.
      # Keep empty until real IDs are ready.
      vpc_id         = ""
      vswitch_id     = ""
      ecs_private_ip = ""
    }

    tags = {
      Project     = "lilly"
      Environment = "dev"
      ManagedBy   = "terraform-terragrunt"
      Owner       = "platform"
    }
  }
}
