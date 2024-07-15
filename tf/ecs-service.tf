resource "aws_ecs_service" "this" {
  # depends_on = [aws_db_instance.this]

  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    base              = 1   # Number of tasks, at a minimum, to run on the specified capacity provider
    weight            = 100 # Relative percentage of the total number of launched tasks that should use the specified capacity provider
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.service_name
    container_port   = local.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}


