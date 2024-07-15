resource "aws_ecs_cluster" "this" {
  name = local.base_name
}

