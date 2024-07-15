# get authorization credentials to push to ecr
data "aws_ecr_authorization_token" "this" {}

data "aws_vpc" "this" {
  id      = var.vpc_id
  default = var.vpc_id == null ? true : null
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

data "aws_ssm_parameter" "ecs_optimized_ami_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "http" "my_ip" {
  url = "https://ipinfo.io/ip"
}
